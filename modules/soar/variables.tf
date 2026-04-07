# Common variables (sourced from global/variables.tfvars)
variable "region" {
    description = "The region to deploy the resources in"
    type        = string
}

variable "tags" {
    description = "A map of tags to assign to resources"
    type        = map(string)
}

variable "env" {
    description = "The environment to deploy the resources in"
    type        = string
}

variable "email" {
    description = "Email address to send notifications to"
    type        = string
}

variable "waf_ip_blacklist_name" {
    description = "WAF blacklist name"
    type        = string
}

variable "waf_ip_blacklist_id" {
    description = "WAF blacklist ID"
    type        = string
}

variable "waf_ip_blacklist_arn" {
    description = "WAF blacklist ARN"
    type        = string
}