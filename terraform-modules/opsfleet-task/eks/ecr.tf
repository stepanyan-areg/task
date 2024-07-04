resource "aws_ecr_repository" "main" {
  for_each = toset(var.ecr)
  name     = each.value
  tags     = var.tags
}