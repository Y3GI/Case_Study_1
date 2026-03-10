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

# Monitoring-specific variables
variable "vpn_sg_id" {
    description = "VPN access security group ID (from root or pre-created)"
    type        = string
    default     = ""  # Can be provided or left empty if using root SG
}

variable "budget_limit" {
    description = "Monthly budget limit in USD"
    type        = number
    default     = 350
}