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

# Budget-specific variables
variable "limit_amount" {
    description = "The limit amount for the budget"
    type        = number
    default     = 350
}

variable "plg_ec2_instance_type" {
    description = "The size of the EC2 instance for the PLG monitoring solution"
    type        = string
    default     = "t3.micro"
}