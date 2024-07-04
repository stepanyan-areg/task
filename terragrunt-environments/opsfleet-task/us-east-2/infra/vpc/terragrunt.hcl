# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../../../terraform-modules/opsfleet-task/vpc"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

inputs = {
  cidr                 = "172.16.0.0/16"
  public_subnet_cidrs  = ["172.16.0.0/24", "172.16.1.0/24", "172.16.2.0/24"]
  private_subnet_cidrs = ["172.16.10.0/24", "172.16.11.0/24", "172.16.12.0/24"]
  azs                  = ["us-east-2a", "us-east-2b", "us-east-2c"]
}
