output "alb_arn" {
  description = "The ARN of the ALB"
  value       = aws_lb.alb.arn
}

output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.alb.dns_name
}

output "alb_public_url" {
  description = "The public URL of the ALB"
  value       = "https://${aws_lb.alb.dns_name}"
}

output "alb_zone_id" {
  description = "The zone ID of the ALB"
  value       = aws_lb.alb.zone_id
}

output "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.web_app.arn
}

output "lambda_function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.web_app.function_name
}

output "lambda_function_invoke_arn" {
  description = "The invoke ARN of the Lambda function"
  value       = aws_lambda_function.web_app.invoke_arn
}

output "lambda_target_group_arn" {
  description = "The ARN of the Lambda target group"
  value       = aws_lb_target_group.lambda_tg.arn
}

output "lambda_target_group_name" {
  description = "The name of the Lambda target group"
  value       = aws_lb_target_group.lambda_tg.name
}

output "alb_listener_arn" {
  description = "The ARN of the ALB listener"
  value       = aws_lb_listener.alb_listener.arn
}

output "lambda_sg_id" {
  description = "The ID of the Lambda security group"
  value       = aws_security_group.lambda_sg.id
}

output "alb_sg_id" {
  description = "The ID of the ALB security group"
  value       = aws_security_group.alb_sg.id
}