include "root" {
  path = find_in_parent_folders()
}

include "common" {
  path   = "${dirname(find_in_parent_folders())}/terragrunt.hcl"
  expose = true
}

terraform {
  source = "../../../../terraform/modules//ssm-agent"
}

# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------

locals {

}

dependency "vpc" {
  config_path = "../infra"

  mock_outputs_allowed_terraform_commands = ["validate"]
  mock_outputs = {
    vpc_id = "fake-vpc-id"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Override parameters for this environment
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  vpc_id     = dependency.vpc.outputs.vpc_id
  subnet_ids = dependency.vpc.outputs.private_subnets
  tags       = merge(
    include.common.locals.common_tags,
    {
      Name = "ssm_instance"
    }
  )
  user_data  = <<EOT
    #!/bin/bash
    sudo yum install -y nc
    echo 'export HELLO_WORLD="Hello World!"' >> ~/.bash_profile
  EOT
}