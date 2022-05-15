// image
// IAM role
// asg


data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_ami" "amazon_linux_2" {
    most_recent = true
    owners = ["amazon"]

    filter {
        name = "name"
        values = ["amzn2-ami-hvm*"]
    }

    filter {
        name = "architecture"
        values = ["x86_64"]
    }
}

locals {
  region     = coalesce(var.aws_region, data.aws_region.current.name)
  account_id = data.aws_caller_identity.current.account_id
  map_tags = [
      for key, value in var.tags: {
          key                 = key
          value               = value
          propagate_at_launch = true
      }
  ]
}



####################
## IAM Role        
####################

data "aws_iam_policy_document" "this" {

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name                 = "${var.resource_prefix}allow-ssm"
  assume_role_policy   = data.aws_iam_policy_document.this.json
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.resource_prefix}ssm-agent-profile"
  role = aws_iam_role.this.name
}

####################
## SECURITY GROUP 
####################

resource "aws_security_group" "this" {
  vpc_id      = var.vpc_id
  name        = "${var.resource_prefix}sg-ssm-agent"
  description = "Allow ALL egress from SSM Agent."
}

resource "aws_security_group_rule" "allow_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "allow_all_ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  self              = true
  security_group_id = aws_security_group.this.id
}

#########################
## LAUNCH TEMPLATE + ASG 
#########################

resource "aws_launch_template" "this" {
  name_prefix   = "${var.resource_prefix}template"
  image_id      = var.ami != "" ? var.ami : data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  user_data     = base64encode(var.user_data)

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    security_groups             = concat(var.additional_security_group_ids, [aws_security_group.this.id])
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.this.name
  }

  tag_specifications {
    resource_type = "instance"
    tags          = var.tags
  }

  tag_specifications {
    resource_type = "volume"
    tags          = var.tags
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "this" {
  name_prefix = "${var.resource_prefix}asg"
  tags        = local.map_tags

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  max_size         = var.max_instance_count
  min_size         = var.min_instance_count
  desired_capacity = var.desired_instance_count

  vpc_zone_identifier = var.subnet_ids

  default_cooldown          = 180
  health_check_grace_period = 180
  health_check_type         = "EC2"

  termination_policies = [
    "OldestLaunchConfiguration",
  ]

  lifecycle {
    create_before_destroy = true
  }
}