
# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../../../terraform-modules/opsfleet-task/eks"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  vpc            = dependency.vpc.outputs.vpc_id
  subnets        = dependency.vpc.outputs.private_subnets
  // access_entries = local.access_entries
}
