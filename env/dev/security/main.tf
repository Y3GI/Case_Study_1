terraform {
    backend "s3" {}

    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 6.0"
        }
    }
}

provider "aws" {
    region = var.region

    default_tags {
        tags = var.tags
    }
}

data "aws_caller_identity" "current" {}

# Call the security module
module "security" {
    source = "../../../modules/security"

    region = var.region
    env    = var.env
    tags   = var.tags
    email  = var.email
}