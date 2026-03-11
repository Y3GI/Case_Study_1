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

# Storage-specific variables
variable "lambda_sg_id" {
    description = "Lambda security group ID (from root or pre-created)"
    type        = string
    default     = ""  # Can be provided or left empty if using root SG
}

variable "aurora_cluster_endpoint" {
    description = "Aurora cluster endpoint (placeholder)"
    type        = string
    default     = "db.internal"
}

variable "aurora_instances" {
    description = "Aurora RDS instance configuration"
    type = map(object({
        instance_class = string
    }))
    default = {
        "instance_1" = {
            instance_class = "db.t4g.small"
        }
        "instance_2" = {
            instance_class = "db.t4g.small"
        }
    }
}

variable "db_cluster_endpoint" {
  description = "db cluster endpoint"
  type        = string
}