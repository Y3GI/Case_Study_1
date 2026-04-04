output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.monitoring.name
}

output "ecs_cluster_arn" {
  description = "The ARN of the ECS cluster"
  value       = aws_ecs_cluster.monitoring.arn
}

output "ecs_service_name" {
  description = "The name of the ECS service"
  value       = aws_ecs_service.monitoring_ecs.name
}

output "ecs_service_arn" {
  description = "The ARN of the ECS service"
  value       = aws_ecs_service.monitoring_ecs.arn
}

output "ecs_task_definition_arn" {
  description = "The ARN of the ECS task definition"
  value       = aws_ecs_task_definition.monitoring_stack.arn
}

output "ecs_task_definition_family" {
  description = "The family name of the ECS task definition"
  value       = aws_ecs_task_definition.monitoring_stack.family
}

output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.monitoring_logs.name
}

output "cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.monitoring_logs.arn
}

output "ecs_execution_role_arn" {
  description = "The ARN of the ECS task execution role"
  value       = aws_iam_role.ecs_execution_role.arn
}

output "ecs_execution_role_name" {
  description = "The name of the ECS task execution role"
  value       = aws_iam_role.ecs_execution_role.name
}

output "monitoring_security_group_id" {
  description = "The ID of the monitoring stack security group"
  value       = aws_security_group.monitoring_stack_sg.id
}

output "alb_logs_bucket_name" {
  description = "The name of alb logs bucket"
  value       = aws_s3_bucket.alb_logs.name
}

output "alb_logs_bucket_arn" {
  description = "The arn of alb logs bucket"
  value       = aws_s3_bucket.alb_logs.arn
}

output "alb_logs_bucket_id" {
  description = "The id of alb logs bucket"
  value       = aws_s3_bucket.alb_logs.id
}