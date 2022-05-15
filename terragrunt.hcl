locals {
    env_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl")).locals
    region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals
    global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl")).locals
    resource_prefix = "${local.global_vars.stack}-${local.region_vars.region}-${local.env_vars.env}-"
    bucket_state_name = "${local.resource_prefix}tfstate"
    common_tags = {
        "Owner" = local.global_vars.owner,
        "Stack" = local.global_vars.stack,
        "Environment" = local.env_vars.env,
        "Region" = local.region_vars.aws_region,
        "State" = local.bucket_state_name
    }
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket = "${local.bucket_state_name}"
    key = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.region_vars.aws_region
    encrypt        = true
    dynamodb_table = "${local.bucket_state_name}-table"
    s3_bucket_tags = merge(
        local.common_tags
        )
    dynamodb_table_tags = merge(
        local.common_tags
        )
    }
}

generate "provider" {
    path = "override.tf"
    if_exists = "overwrite"
    contents = <<EOF

terraform {
    required_version = ">= 1.1.0"
    required_providers {
        aws = {
            version = "= 4.14.0"
        }
    }
}

provider "aws" {
    region = var.aws_region
    default_tags {
        tags = jsondecode(var.common_tags)
    }
}

EOF
}


generate "common" {
    path = "common.tf"
    if_exists = "overwrite"
    contents = <<EOF

variable "common_tags" {}
variable "resource_prefix" {}
variable "aws_region" {}
variable "owner" {}
variable "stack" {}
variable "env" {}

EOF
}


inputs = merge(
    local.env_vars,
    local.region_vars,
    local.global_vars,
    {
        resource_prefix = local.resource_prefix,
        common_tags = local.common_tags,
    }
)