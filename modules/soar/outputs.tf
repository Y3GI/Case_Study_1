output "lambda_soar_function_name" {
    description = "Name of the SOAR Lambda responder function"
    value       = aws_lambda_function.soar_responder.function_name
}

output "lambda_soar_function_arn" {
    description = "ARN of the SOAR Lambda responder function"
    value       = aws_lambda_function.soar_responder.arn
}

output "lambda_soar_role_arn" {
    description = "ARN of the SOAR Lambda execution role"
    value       = aws_iam_role.soar_lambda_role.arn
}

output "sns_topic_arn" {
    description = "ARN of the SNS topic for Grafana alerts"
    value       = aws_sns_topic.sns.arn
}

output "sns_topic_name" {
    description = "Name of the SNS topic for Grafana alerts"
    value       = aws_sns_topic.sns.name
}