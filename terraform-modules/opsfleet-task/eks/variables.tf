variable "environment" {
  description = "Environment tag, e.g prod"
  type        = string
}

variable "kube_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.30"
}

variable "vpc" {
  description = "VPC Id"
  type        = string
}

variable "subnets" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "ecr" {
  description = "List of ECR repositories to create"
  type        = list(string)
  default     = []
}

variable "aws_auth_users" {
  description = "List of IAM users to add to aws-auth configmap"
  type        = list(any)
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# variable "access_entries" {
#   description = "A map of access entries to add to the cluster"
#   type        = map(object({
#       kubernetes_groups = ["admin"]
#       principal_arn     = "arn:aws:iam::115525075501:user/dev"
#   }))
# }