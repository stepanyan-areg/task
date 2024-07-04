variable "cidr" {
  description = "The CIDR block for the VPC."
}

variable "public_subnet_cidrs" {
  description = "List of external subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of internal subnets"
  type        = list(string)
}

variable "environment" {
  description = "Environment tag, e.g prod"
  type        = string
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "create_vpn_gateway" {
  description = "Create a VPN gateway"
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Provision only one nat gateway"
  type        = bool
  default     = true
}
