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

output "waf_ip_set_name" {
    description = "Name of the WAF IP set for blacklisting"
    value       = aws_wafv2_ip_set.waf_ip_blacklist.name
}

output "waf_ip_set_arn" {
    description = "ARN of the WAF IP set for blacklisting"
    value       = aws_wafv2_ip_set.waf_ip_blacklist.arn
}

output "waf_ip_set_id" {
    description = "ID of the WAF IP set for blacklisting"
    value       = aws_wafv2_ip_set.waf_ip_blacklist.id
}

output "waf_name" {
    description = "Name of the WAF"
    value       = aws_wafv2_web_acl.waf.name
}

output "waf_arn" {
    description = "ARN of the WAF"
    value       = aws_wafv2_web_acl.waf.arn
}

output "waf_id" {
    description = "ID of the WAF"
    value       = aws_wafv2_web_acl.waf.id
}
