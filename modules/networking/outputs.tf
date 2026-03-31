output "public_vpc_id" {
  description = "The ID of the public VPC"
  value       = aws_vpc.public.id
}

output "public_vpc_cidr" {
  description = "The CIDR block of the public VPC"
  value       = aws_vpc.public.cidr_block
}

output "private_vpc_id" {
  description = "The ID of the private VPC"
  value       = aws_vpc.private.id
}

output "private_vpc_cidr" {
  description = "The CIDR block of the private VPC"
  value       = aws_vpc.private.cidr_block
}

output "internet_gateway_id" {
  description = "The ID of the internet gateway"
  value       = aws_internet_gateway.igw.id
}

output "public_subnets" {
  description = "Map of public subnet IDs"
  value       = { for k, v in aws_subnet.public : k => v.id }
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnets" {
  description = "Map of private subnet IDs"
  value       = { for k, v in aws_subnet.private : k => v.id }
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "lambda_subnet_ids" {
  description = "List of subnet IDs for Lambda"
  value       = [aws_subnet.private["lambda_subnet1"].id, aws_subnet.private["lambda_subnet2"].id]
}

output "db_subnet_group_name" {
  description = "The name of the DB subnet group"
  value       = aws_db_subnet_group.aurora_db_subnet_group.name
}

output "db_subnet_group_arn" {
  description = "The ARN of the DB subnet group"
  value       = aws_db_subnet_group.aurora_db_subnet_group.arn
}

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "The ID of the private route table"
  value       = aws_route_table.private.id
}

output "vpn_endpoint_id" {
  description = "The ID of the VPN endpoint"
  value       = aws_ec2_client_vpn_endpoint.vpn.id
}

output "vpn_endpoint_arn" {
  description = "The ARN of the VPN endpoint"
  value       = aws_ec2_client_vpn_endpoint.vpn.arn
}

output "vpn_endpoint_dns_name" {
  description = "The DNS name of the VPN endpoint"
  value       = aws_ec2_client_vpn_endpoint.vpn.dns_name
}

output "vpn_access_security_group_id" {
  description = "The ID of the VPN access security group"
  value       = aws_security_group.vpn_access.id
}

output "secretsmanager_endpoint_id" {
  description = "The ID of the Secrets Manager VPC endpoint"
  value       = aws_vpc_endpoint.secretsmanager.id
}

output "ecr_api_endpoint_id" {
  description = "Map of ECR API VPC endpoint IDs"
  value       = aws_vpc_endpoint.ecr_api.id
}

output "ecr_dkr_endpoint_id" {
  description = "Map of ECR Docker VPC endpoint IDs"
  value       = aws_vpc_endpoint.ecr_dkr.id 
}

output "cloudwatch_logs_endpoint_id" {
  description = "Map of CloudWatch Logs VPC endpoint IDs"
  value       = aws_vpc_endpoint.cloudwatch_logs.id
}

output "s3_endpoint_id" {
  description = "The ID of the S3 VPC endpoint"
  value       = aws_vpc_endpoint.s3.id
}

output "monitoring_endpoint_security_group_id" {
  description = "Map of monitoring endpoint security group IDs"
  value       = aws_security_group.monitoring_endpoint_sg.id
}

output "rds_endpoint_security_group_id" {
  description = "The ID of the RDS endpoint security group"
  value       = aws_security_group.rds_endpoint.id
}
