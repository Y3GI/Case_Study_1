terraform {
    backend "s3" {}

    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 6.0"
        }
        random = {
            source  = "hashicorp/random"
            version = "~> 3.0"
        }
    }
}

provider "aws" {
    region = var.region

    default_tags {
        tags = var.tags
    }
}

module "soar" {
    source = "../../../modules/soar"

    region                  = var.region
    env                     = var.env
    tags                    = var.tags
    email                   = var.email
}