output "lambda_soar_function_name" {
    description = "Name of the SOAR Lambda responder function"
    value       = module.soar.lambda_soar_function_name
}

output "lambda_soar_function_arn" {
    description = "ARN of the SOAR Lambda responder function"
    value       = module.soar.lambda_soar_function_arn
}

output "lambda_soar_role_arn" {
    description = "ARN of the SOAR Lambda execution role"
    value       = module.soar.lambda_soar_role_arn
}

output "sns_topic_arn" {
    description = "ARN of the SNS topic for Grafana alerts"
    value       = module.soar.sns_topic_arn
}

output "sns_topic_name" {
    description = "Name of the SNS topic for Grafana alerts"
    value       = module.soar.sns_topic_name
}