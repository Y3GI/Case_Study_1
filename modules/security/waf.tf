resource "aws_cloudwatch_log_group" "waf_logs" {
    name = "aws-waf-logs-${var.env}-main-waf"
    retention_in_days = 7

    tags = var.tags
}

resource "aws_wafv2_web_acl_logging_configuration" "waf_logging" {
    log_destination_configs = [aws_cloudwatch_log_group.waf_logs.arn]
    resource_arn            = aws_wafv2_web_acl.waf.arn

    logging_filter {
        default_behavior = "KEEP"

        filter {
            behavior = "KEEP"
            condition {
                action_condition {
                    action = "BLOCK"
                }
            }
            requirement = "MEETS_ANY"
        }
    }
}

resource "aws_wafv2_ip_set" "waf_ip_blacklist" {
    description = "Web application firewall IP blacklist"
    scope = "REGIONAL"
    ip_address_version = "IPV4"
    addresses = []

    tags = merge(var.tags, {
        Name = "${var.env}-waf-ip-blacklist"
    })
}

resource "aws_wafv2_web_acl" "waf" {
    description = "WAF for the public ALB"
    scope = "REGIONAL"

    default_action {
        allow {} # By default, let people in
    }

    rule {
        name     = "soar-auto-block-rule"
        priority = 1 # Highest priority - evaluate this first!
    
        action {
            block {} # If they are on the list, block them immediately
        }

        statement {
            ip_set_reference_statement {
                arn = aws_wafv2_ip_set.waf_ip_blacklist.arn
            }
        }
    
        visibility_config {
            cloudwatch_metrics_enabled = true
            metric_name                = "soar-blocked-ips"
            sampled_requests_enabled   = true
        }
    }

    visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "main-waf-metrics"
        sampled_requests_enabled   = true
    }
}
