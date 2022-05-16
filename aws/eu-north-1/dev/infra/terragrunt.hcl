include "root" {
  path = find_in_parent_folders()
}   

include "vpc" {
   path   = "${dirname(find_in_parent_folders())}/terraform/common/vpc.hcl"
   expose = true
}

include "common" {
  path   = "${dirname(find_in_parent_folders())}/terragrunt.hcl"
  expose = true
}

dependency "data" {
  config_path = "../data"

  mock_outputs_allowed_terraform_commands = ["validate"]
  mock_outputs = {
    aws_availability_zones = {}
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------

locals {
    vpc_cidr = "172.32.0.0/21"
    public_subnets  = slice(cidrsubnets(local.vpc_cidr, 3,3,3,3,3,3), 0, 3) 
    private_subnets = slice(cidrsubnets(local.vpc_cidr, 3,3,3,3,3,3), 3, 6)
}

# ---------------------------------------------------------------------------------------------------------------------
# Override parameters for this environment
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  name = "${include.common.locals.resource_prefix}vpc"
  cidr = local.vpc_cidr

  azs             = dependency.data.outputs.aws_availability_zones.names
  public_subnets  = local.public_subnets
  private_subnets  = local.private_subnets
  
  vpc_tags = {
    Name = "${include.common.locals.resource_prefix}vpc"
  }

# about network tags requirements for AWS Load Balancer Controller
# https://docs.aws.amazon.com/eks/latest/userguide/network-load-balancing.html 

  public_subnet_tags = {
    # "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/elb"              = 1
  }

  private_subnet_tags = {
    # "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/internal-elb"     = 1
  }

}