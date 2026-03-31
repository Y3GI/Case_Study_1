# Networking outputs from the module
output "public_vpc_id" {
    description = "Public VPC ID"
    value       = module.networking.public_vpc_id
}

output "public_vpc_cidr" {
    description = "Public VPC CIDR"
    value       = module.networking.public_vpc_cidr
}


output "private_vpc_id" {
    description = "Private VPC ID"
    value       = module.networking.private_vpc_id
}

output "private_vpc_cidr" {
    description = "Private VPC CIDR"
    value       = module.networking.private_vpc_cidr
}

output "public_subnet_ids" {
    description = "Public subnet IDs"
    value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
    description = "Private subnet IDs"
    value       = module.networking.private_subnet_ids
}

output "lambda_subnet_ids" {
    description = "Lambda subnet IDs"
    value       = module.networking.lambda_subnet_ids
}

output "db_subnet_group_name" {
    description = "Database subnet group name"
    value       = module.networking.db_subnet_group_name
}

output "vpn_endpoint_id" {
    description = "VPN endpoint ID"
    value       = module.networking.vpn_endpoint_id
}

output "vpn_endpoint_dns_name" {
    description = "VPN endpoint DNS name"
    value       = module.networking.vpn_endpoint_dns_name
}

output "vpn_access_security_group_id" {
    description = "VPN access security group ID"
    value       = module.networking.vpn_access_security_group_id
}

output "vpn_sg_id" {
    description = "VPN security group ID"
    value       = module.networking.vpn_access_security_group_id
}