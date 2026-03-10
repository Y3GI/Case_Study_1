# Compute outputs from the module
output "alb_arn" {
    description = "Application Load Balancer ARN"
    value       = module.compute.alb_arn
}

output "alb_dns_name" {
    description = "ALB DNS name"
    value       = module.compute.alb_dns_name
}

output "alb_public_url" {
    description = "ALB public HTTPS URL"
    value       = module.compute.alb_public_url
}

output "alb_sg_id" {
    description = "ALB security group ID"
    value       = module.compute.alb_sg_id
}

output "lambda_function_arn" {
    description = "Lambda function ARN"
    value       = module.compute.lambda_function_arn
}

output "lambda_function_name" {
    description = "Lambda function name"
    value       = module.compute.lambda_function_name
}

output "lambda_sg_id" {
    description = "Lambda security group ID"
    value       = module.compute.lambda_sg_id
}

output "lambda_target_group_arn" {
    description = "Lambda target group ARN"
    value       = module.compute.lambda_target_group_arn
}
