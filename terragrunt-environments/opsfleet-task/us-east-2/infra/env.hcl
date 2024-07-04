# Set common variables for the environment. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.
locals {
  environment = "dev"

  tags = {
    Environment = local.environment
    Terraform   = "true"
  }

  //   access_entries = {
  //   developer_access = {
  //     kubernetes_groups = ["admin"]
  //     principal_arn     = "arn:aws:iam::115525075501:user/dev"
  //   }
  // }

}
