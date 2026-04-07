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

# Read networking module outputs from S3 state
data "terraform_remote_state" "networking" {
    backend = "s3"
    config = {
        bucket         = "dev-terraform-state-bucket-${data.aws_caller_identity.current.account_id}"
        key            = "env/dev/networking/terraform.tfstate"
        region         = var.region
        encrypt        = true
    }
}

data "terraform_remote_state" "storage" {
    backend = "s3"
    config = {
        bucket         = "dev-terraform-state-bucket-${data.aws_caller_identity.current.account_id}"
        key            = "env/dev/storage/terraform.tfstate"
        region         = var.region
        encrypt        = true
    }
}

data "aws_secretsmanager_secret_version" "db_secret"{
    secret_id = data.terraform_remote_state.storage.outputs.aurora_db_secret_arn
}

locals {
    db_creds = jsondecode(data.aws_secretsmanager_secret_version.db_secret.secret_string)
}

# Call the monitoring module using networking outputs
module "monitoring" {
    source = "../../../modules/monitoring"

    region             = var.region
    env                = var.env
    tags               = var.tags
    email              = var.email
    private_vpc_id     = data.terraform_remote_state.networking.outputs.private_vpc_id
    private_subnet_ids = data.terraform_remote_state.networking.outputs.private_subnet_ids
    private_vpc_cidr   = data.terraform_remote_state.networking.outputs.private_vpc_cidr
    vpn_sg_id          = data.terraform_remote_state.networking.outputs.vpn_sg_id
    db_proxy_endpoint  = data.terraform_remote_state.storage.outputs.rds_proxy_endpoint
    rds_proxy_sg_id    = data.terraform_remote_state.storage.outputs.rds_proxy_security_group_id

    db_username = local.db_creds.username
    db_password = local.db_creds.password

    limit_amount       = var.budget_limit
}