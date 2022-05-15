# https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/v3.12.0
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "v3.12.0"

  name = "vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}


# https://github.com/terraform-aws-modules/terraform-aws-route53

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "v2.5.0"

  zone_name = keys(module.zones.route53_zone_zone_id)[0]

  records = [
    {
      name    = "apigateway1"
      type    = "A"
      alias   = {
        name    = "d-10qxlbvagl.execute-api.eu-west-1.amazonaws.com"
        zone_id = "ZLY8HYME6SFAD"
      }
    },
    {
      name    = ""
      type    = "A"
      ttl     = 3600
      records = [
        "10.10.10.10",
      ]
    },
  ]

  depends_on = [module.zones]
}


# https://github.com/terraform-aws-modules/terraform-aws-alb
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "v6.7.0"

  name = "my-alb"

  load_balancer_type = "application"

  vpc_id             = "vpc-abcde012"
  subnets            = ["subnet-abcde012", "subnet-bcde012a"]
  security_groups    = ["sg-edcd9784", "sg-edcd9785"]

  access_logs = {
    bucket = "my-alb-logs"
  }

  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      targets = [
        {
          target_id = "i-0123456789abcdefg"
          port = 80
        },
        {
          target_id = "i-a1b2c3d4e5f6g7h8i"
          port = 8080
        }
      ]
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Environment = "Test"
  }
}


# https://github.com/terraform-aws-modules/terraform-aws-security-group/releases/tag/v4.8.0
# https://github.com/terraform-aws-modules/terraform-aws-security-group/blob/master/examples/complete/main.tf

module "vote_service_sg" {
  source = "terraform-aws-modules/security-group/aws"
  version = "v4.8.0"

  name        = "user-service"
  description = "Security group for user-service with custom ports open within VPC, and PostgreSQL publicly open"
  vpc_id      = "vpc-12345678"

  ingress_cidr_blocks      = ["10.10.0.0/16"]
  ingress_rules            = ["https-443-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8090
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = "10.10.0.0/16"
    },
    {
      rule        = "postgresql-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}

# https://github.com/terraform-aws-modules/terraform-aws-acm
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "v3.3.0"

  domain_name  = "my-domain.com"
  zone_id      = "Z2ES7B9AZ6SHAE"

  subject_alternative_names = [
    "*.my-domain.com",
    "app.sub.my-domain.com",
  ]

  wait_for_validation = true

  tags = {
    Name = "my-domain.com"
  }
}

# EKS Cluster
# https://github.com/hashicorp/learn-terraform-provision-eks-cluster
# https://github.com/terraform-aws-modules/terraform-aws-eks

# TODO

# ASG
# https://github.com/terraform-aws-modules/terraform-aws-autoscaling
# good example https://github.com/terraform-aws-modules/terraform-aws-autoscaling/tree/master/examples/complete

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "v5.1.1"

  # Autoscaling group
  name = "default-${local.name}"

  vpc_zone_identifier = module.vpc.private_subnets
  min_size            = 0
  max_size            = 1
  desired_capacity    = 1

  # aws ec2 describe-instance-types --region eu-west-1 --filters Name=network-info.efa-supported,Values=true --query "InstanceTypes[*].[InstanceType]" --output text | sort
  instance_type = "t3.micro"
  image_id      = data.aws_ami.amazon_linux.id
  user_data     = base64encode(local.efa_user_data)

  network_interfaces = [
    {
      description                 = "EFA interface example"
      delete_on_termination       = true
      device_index                = 0
      associate_public_ip_address = false
      interface_type              = "efa"
    }
  ]

  tags = local.tags
}


# https://github.com/cloudposse/terraform-aws-ssm-iam-role
module "ssm_iam_role" {
  source           = "git::https://github.com/cloudposse/terraform-aws-ssm-iam-role.git?ref=v0.2.0"
  namespace        = "cp"
  stage            = "prod"
  name             = "app"
  attributes       = ["all"]
  region           = "us-west-2"
  account_id       = "XXXXXXXXXXX"
  assume_role_arns = ["arn:aws:xxxxxxxxxx", "arn:aws:yyyyyyyyyyyy"]
  kms_key_arn      = "arn:aws:kms:us-west-2:123454095951:key/aced568e-3375-4ece-85e5-b35abc46c243"
  ssm_parameters   = ["*"]
  ssm_actions      = ["ssm:GetParametersByPath", "ssm:GetParameters"]
}