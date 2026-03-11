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

# Aurora RDS variables
variable "subnet_group_name" {
    description = "The name of the DB subnet group for Aurora RDS"
    type        = string
}

variable "private_vpc_id" {
    description = "The ID of the private VPC"
    type        = string
}

variable "private_subnet_ids" {
    description = "List of private subnet IDs for the DB and Proxy"
    type        = list(string)
}


variable "db_cluster_endpoint" {
    description = "The endpoint of the Aurora RDS cluster"
    type        = string
}


variable "lambda_sg_id" {
    description = "The ID of the security group for Lambda functions to access Aurora RDS"
    type        = string
}

#Secrets Manager variables
variable "aurora_cluster_endpoint" {
    description = "The endpoint of the Aurora RDS cluster to store credentials for"
    type        = string
}

variable "aurora_instances"{
    description = "Number of instances for Aurora rds"
    type = map(object({
        instance_class = string
    }))
    default = {
        "instance_1" = {
            instance_class = "db.t3.medium"
        }
    }
}