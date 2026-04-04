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
