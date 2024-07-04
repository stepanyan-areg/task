# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../../../terraform-modules/opsfleet-task/karpenter"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependency "eks" {
  config_path = "../eks"
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  cluster_name       = dependency.eks.outputs.cluster_name
  oidc_provider      = dependency.eks.outputs.oidc_provider
  oidc_provider_arn  = dependency.eks.outputs.oidc_provider_arn
  private_subnet_ids = dependency.vpc.outputs.private_subnets  
}
