# Monitoring outputs from the module
output "ecs_cluster_name" {
    description = "ECS cluster name"
    value       = module.monitoring.ecs_cluster_name
}

output "ecs_cluster_arn" {
    description = "ECS cluster ARN"
    value       = module.monitoring.ecs_cluster_arn
}

output "ecs_service_name" {
    description = "ECS service name"
    value       = module.monitoring.ecs_service_name
}

output "ecs_service_arn" {
    description = "ECS service ARN"
    value       = module.monitoring.ecs_service_arn
}

output "cloudwatch_log_group_name" {
    description = "CloudWatch log group name"
    value       = module.monitoring.cloudwatch_log_group_name
}

output "cloudwatch_log_group_arn" {
    description = "CloudWatch log group ARN"
    value       = module.monitoring.cloudwatch_log_group_arn
}

output "monitoring_security_group_id" {
    description = "Monitoring stack security group ID"
    value       = module.monitoring.monitoring_security_group_id
}

output "alb_logs_bucket" {
    description = "ALB logs bucket ARN"
    value       = module.monitoring.alb_logs_bucket
}
