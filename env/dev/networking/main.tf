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

# Call the networking module
module "networking" {
    source = "../../../modules/networking"

    region = var.region
    env    = var.env
    tags   = var.tags
    email  = var.email
}