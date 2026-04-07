output "waf_ip_set_name" {
    description = "Name of the WAF IP set for blacklisting"
    value       = module.security.waf_ip_set_name
}

output "waf_ip_set_arn" {
    description = "ARN of the WAF IP set for blacklisting"
    value       = module.security.waf_ip_set_arn
}

output "waf_ip_set_id" {
    description = "ID of the WAF IP set for blacklisting"
    value       = module.security.waf_ip_set_id
}

output "waf_name" {
    description = "Name of the WAF"
    value       = module.security.waf_name
}

output "waf_arn" {
    description = "ARN of the WAF"
    value       = module.security.waf_arn
}

output "waf_id" {
    description = "ID of the WAF"
    value       = module.security.waf_id
}