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

data "terraform_remote_state" "certificates" {
    backend = "s3"
        config = {
        bucket         = "dev-terraform-state-bucket-${data.aws_caller_identity.current.account_id}"
        key            = "env/dev/certificates/terraform.tfstate"
        region         = var.region
        encrypt        = true
    }
}

# Call the networking module
module "networking" {
    source = "../../../modules/networking"

    region = var.region
    env    = var.env
    tags   = var.tags
    email  = var.email
    server_cert_arn = data.terraform_remote_state.certificates.outputs.server_cert_arn
    client_cert_arn = data.terraform_remote_state.certificates.outputs.client_cert_arn

}