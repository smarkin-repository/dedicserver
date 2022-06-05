provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
  }
}

locals {
  name            = "${var.resource_prefix}eks"
  cluster_version = "1.22"
  region          = var.aws_region
  tags            = {}
}


data "aws_caller_identity" "current" {}

################################################################################
# EKS Module
################################################################################

module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "v18.7.2"

  cluster_name                    = local.name
  cluster_version                 = local.cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
    }
  }

  cluster_encryption_config = [{
    provider_key_arn = aws_kms_key.eks.arn
    resources        = ["secrets"]
  }]

  cluster_tags = {
    # This should not affect the name of the cluster primary security group
    # Ref: https://github.com/terraform-aws-modules/terraform-aws-eks/pull/2006
    # Ref: https://github.com/terraform-aws-modules/terraform-aws-eks/pull/2008
    Name = local.name
  }

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  # Extend cluster security group rules
  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
    ingress_nodes_ephemeral_ports_udp = {
      description                = "To node 7000-8000"
      protocol                   = "udp"
      from_port                  = 7000
      to_port                    = 8000
      type                       = "ingress"
      cidr_blocks                = ["0.0.0.0/0", var.vpc_cidr_block]
      # ipv6_cidr_blocks           = ["::/0"]
      # source_node_security_group = true
    }
    engress_all = {
      description                = "To all"
      protocol                   = "-1"
      from_port                  = 0
      to_port                    = 0
      type                       = "egress"
      cidr_blocks                = ["0.0.0.0/0"]
    }
    
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["m6i.large", "m5.large", "m5n.large", "t4g.medium", "t3.large", "t3.medium"]
    disk_size      = 50
    # We are using the IRSA created below for permissions
    # However, we have to deploy with the policy attached FIRST (when creating a fresh cluster)
    # and then turn this off after the cluster/node group is created. Without this initial policy,
    # the VPC CNI fails to assign IPs and nodes cannot join the cluster
    # See https://github.com/aws/containers-roadmap/issues/1666 for more context
    iam_role_attach_cni_policy   = true
    iam_role_additional_policies = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
  }

  eks_managed_node_groups = {
    complete = {
    #   name            = "${local.name}eks-mng"
    #   use_name_prefix = true
      subnet_ids = var.subnet_ids
      instance_types = var.instance_types
      capacity_type = "SPOT"

      min_size     = 1
      max_size     = 3
      desired_size = 1

      ami_id                     = data.aws_ssm_parameter.ami.value # data.aws_ami.eks_default.image_id
      enable_bootstrap_user_data = true
      update_config = {
        max_unavailable_percentage = 50 # or set `max_unavailable`
      }

      description = "EKS managed node group example launch template"
    #   enable_monitoring       = true

    }

    # agones-system = {
    #   instance_types = "t3.medium"
    #   asg_desired_capacity = 1
    #   kubelet_extra_args   = "--node-labels=agones.dev/agones-system=true --register-with-taints=agones.dev/agones-system=true:NoExecute"
    #   public_ip            = true
    # }
    # agones-metrics = {
    #   instance_type        = var.machine_type
    #   asg_desired_capacity = 1
    #   kubelet_extra_args   = "--node-labels=agones.dev/agones-metrics=true --register-with-taints=agones.dev/agones-metrics=true:NoExecute"
    #   public_ip            = true
    # }


  }

  tags = local.tags
}

# References to resources that do not exist yet when creating a cluster will cause a plan failure due to https://github.com/hashicorp/terraform/issues/4149
# There are two options users can take
# 1. Create the dependent resources before the cluster => `terraform apply -target <your policy or your security group> and then `terraform apply`
#   Note: this is the route users will have to take for adding additonal security groups to nodes since there isn't a separate "security group attachment" resource
# 2. For addtional IAM policies, users can attach the policies outside of the cluster definition as demonstrated below
# resource "aws_iam_role_policy_attachment" "additional" {
#   for_each = module.eks.eks_managed_node_groups
#   policy_arn = aws_iam_policy.node_additional.arn
#   role       = each.value.iam_role_name
# }

# resource "aws_iam_role_policy_attachment" "ssm-allow" {
#     for_each   = module.eks.eks_managed_node_groups
#     role       = each.value.iam_role_name
#     policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
# }

################################################################################
# Supporting Resources
################################################################################

module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "v4.12.0"

  role_name_prefix      = "VPC-CNI-IRSA"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv6   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

  tags = local.tags
}

resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = local.tags
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
}

resource "aws_key_pair" "this" {
  key_name_prefix = local.name
  public_key      = tls_private_key.this.public_key_openssh

  tags = local.tags
}


resource "aws_iam_policy" "node_additional" {
  name        = "${local.name}-additional"
  description = "Example usage of node additional policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })

  tags = local.tags
}

data "aws_ami" "eks_default" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-${local.cluster_version}-v*"]
  }
}

data "aws_ssm_parameter" "ami" {
  name = "/aws/service/eks/optimized-ami/1.22/amazon-linux-2/recommended/image_id"
}

