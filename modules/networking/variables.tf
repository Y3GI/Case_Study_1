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

# VPC variables
variable "public_vpc_cidr" {
    description = "The CIDR block for the VPC"
    type        = string
    default     = "10.1.0.0/16"
}

variable "private_vpc_cidr" {
    description = "The CIDR block for the private subnet"
    type        = string
    default     = "10.2.0.0/16"
}

# Subnet variables
variable "public_subnet_cidrs" {
    description = "The CIDR blocks for the public subnets"
    type        = map(object({
        cidr_block = string
        az         = string
    }))
    default     = {
        "alb_subnet1" = {
            cidr_block = "10.1.1.0/24"
            az         = "eu-central-1a"
        }
        "alb_subnet2" = {
            cidr_block = "10.1.2.0/24"
            az         = "eu-central-1b"
        }
    }
}

variable "private_subnet_cidrs" {
    description = "The CIDR blocks for the private subnets"
    type        = map(object({
        cidr_block = string
        az         = string
    }))
    default     = {
        "subnet1" = {
            cidr_block = "10.2.1.0/24"
            az         = "eu-central-1a"
        }
        "db_subnet1" = {
            cidr_block = "10.2.2.0/24"
            az         = "eu-central-1a"
        }
        "db_subnet2" = {
            cidr_block = "10.2.3.0/24"
            az         = "eu-central-1b"
        }
        "lambda_subnet1" = {
            cidr_block = "10.2.4.0/24"
            az         = "eu-central-1a"
        }
        "lambda_subnet2" = {
            cidr_block = "10.2.5.0/24"
            az         = "eu-central-1b"
        }
    }
}

# Instance type variable for VPC resources (e.g., NAT Gateway)
variable "vpc_instance_type" {
    description = "The instance type for the VPC resources (e.g., NAT Gateway)"
    type        = string
    default     = "t3.micro"
}

# Availability zones variable
variable "azs" {
    description = "Availability zones to deploy the resources in"
    type = list(string)
    default = ["eu-central-1a"]
}

# VPN certificate variable

variable "server_cert_arn" {
    description = "ARN of the certificate to use for VPN connections"
    type        = string
    default     = ""
}

variable "client_cert_arn" {
    description = "ARN of the certificate to use for VPN client authentication"
    type        = string
    default     = ""
}

variable "vpn_cidr_block" {
    description = "The CIDR block for the VPN clients"
    type        = string
    default     = "10.100.0.0/22"
}