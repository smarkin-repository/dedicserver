# ---------------------------------------------------------------------------------------------------------------------
# COMMON TERRAGRUNT CONFIGURATION
# This is the common component configuration for mysql. The common variables for each environment to
# deploy mysql are defined here. This configuration will be merged into the environment configuration
# via an include block.
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  source = "${local.base_source_url}?ref=v3.12.0"
}

# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Expose the base source URL so different versions of the module can be deployed in different environments. This will
  # be used to construct the terraform block in the child terragrunt configurations.
  # base_source_url = "git::git@github.com:smarkin-repository/dedicserver.git//vpc"
  base_source_url = "git::git@github.com:terraform-aws-modules/terraform-aws-vpc.git//"
}


# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  enable_nat_gateway     = true
  single_nat_gateway     = true
  enable_vpn_gateway     = false
  one_nat_gateway_per_az = false
  enable_dns_hostnames   = true
  enable_dns_support     = true
}