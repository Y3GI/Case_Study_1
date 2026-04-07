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

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "security" {
    backend = "s3"
    config = {
        bucket         = "dev-terraform-state-bucket-${data.aws_caller_identity.current.account_id}"
        key            = "env/dev/security/terraform.tfstate"
        region         = var.region
        encrypt        = true
    }
}

module "soar" {
    source = "../../../modules/soar"

    region                  = var.region
    env                     = var.env
    tags                    = var.tags
    email                   = var.email

    waf_ip_blacklist_id     = data.terraform_remote_state.security.outputs.waf_ip_blacklist_id
    waf_ip_blacklist_name   = data.terraform_remote_state.security.outputs.waf_ip_blacklist_name
    waf_ip_blacklist_arn    = data.terraform_remote_state.security.outputs.waf_ip_blacklist_arn 
}