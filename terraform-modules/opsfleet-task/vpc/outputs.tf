# VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.main.vpc_id
}

# Subnets
output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.main.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.main.public_subnets
}

# NAT gateways
output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.main.nat_public_ips
}

output "public_route_table_ids" {
  description = "List of IDs of public route tables"
  value       = module.main.public_route_table_ids
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = module.main.private_route_table_ids
}

output "vpc_default_security_group_id" {
  description = "The default security group id of the VPC"
  value       = data.aws_security_group.default.id
}