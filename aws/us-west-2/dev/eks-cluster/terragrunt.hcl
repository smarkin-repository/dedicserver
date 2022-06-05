include "root" {
  path = find_in_parent_folders()
}

include "common" {
  path   = "${dirname(find_in_parent_folders())}/terragrunt.hcl"
  expose = true
}

terraform {
  source = "../../../../terraform/modules//eks"
}

# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------

locals {

}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs_allowed_terraform_commands = ["validate"]
  mock_outputs = {
    vpc_id = "fake-vpc-id"
    private_subnets = ["172.21.0.0/24"]
    public_subnets  = ["172.21.0.0/24"]
    vpc_cidr_block =   "172.32.0.0/21"
  }
}

dependency "data" {
  config_path = "../data"

  mock_outputs_allowed_terraform_commands = ["validate"]
  mock_outputs = {
    caller = {}
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Override parameters for this environment
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  vpc_id         = dependency.vpc.outputs.vpc_id
  vpc_cidr_block = dependency.vpc.outputs.vpc_cidr_block
  subnet_ids     = dependency.vpc.outputs.private_subnets # concat(dependency.vpc.outputs.private_subnets , dependency.vpc.outputs.public_subnets)
  caller         = dependency.data.outputs.caller
  # tags       = merge(
  #   include.common.locals.common_tags,
  #   {
  #     Name = "ssm_instance"
  #   }
  # )
}