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

variable "private_vpc_id" {
    description = "The ID of the private VPC for the compute resources"
    type        = string
}

variable "public_vpc_id" {
    description = "The ID of the public VPC for the compute resources"
    type        = string
}

variable "rds_proxy_sg_id" {
    description = "The ID of the security group that allows access to Aurora RDS"
    type        = string
}

variable "public_alb_subnet_ids" {
    description = "A list of public subnet IDs for the ALB"
    type        = list(string)
}

variable "private_lambda_subnet_ids" {
    description = "A list of private subnet IDs for the Lambda functions"
    type        = list(string)
}

variable "aurora_proxy_endpoint" {
    description = "The endpoint of the Aurora RDS cluster to connect to"
    type        = string
}

variable "aurora_username" {
    description = "The username to connect to the Aurora RDS cluster"
    type        = string
}

variable "aurora_password" {
    description = "The password to connect to the Aurora RDS cluster"
    type        = string
}

variable "alb_cert_arn" {
    description = "Encription certificate for alb"
    type        = string
}