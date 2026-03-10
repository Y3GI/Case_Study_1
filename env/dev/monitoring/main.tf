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

# Read networking module outputs from S3 state
data "terraform_remote_state" "networking" {
    backend = "s3"
    config = {
        bucket         = "dev-terraform-state-bucket-${data.aws_caller_identity.current.account_id}"
        key            = "dev/networking/terraform.tfstate"
        region         = var.region
        encrypt        = true
        dynamodb_table = "terraform-locks"
    }
}

# Call the monitoring module using networking outputs
module "monitoring" {
    source = "../../modules/monitoring"

    region             = var.region
    env                = var.env
    tags               = var.tags
    email              = var.email
    private_vpc_id     = data.terraform_remote_state.networking.outputs.private_vpc_id
    private_subnet_ids = data.terraform_remote_state.networking.outputs.private_subnet_ids
    vpn_sg_id          = var.vpn_sg_id  # From root or pre-created
    limit_amount       = var.budget_limit
}