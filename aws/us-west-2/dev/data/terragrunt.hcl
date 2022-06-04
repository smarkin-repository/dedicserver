include "root" {
  path = find_in_parent_folders()
}   

terraform {
  source = "../../../../terraform/modules//data"
}

# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------

locals {}

# ---------------------------------------------------------------------------------------------------------------------
# Override parameters for this environment
# ---------------------------------------------------------------------------------------------------------------------
inputs = {}