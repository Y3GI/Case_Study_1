terraform {
    backend "s3" {}

    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 6.0"
        }
        archive = {
            source  = "hashicorp/archive"
            version = "~> 2.0"
        }
        local = {
            source  = "hashicorp/local"
            version = "~> 2.0"
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
        key            = "env/dev/networking/terraform.tfstate"
        region         = var.region
        encrypt        = true
    }
}

# Read storage module outputs from S3 state
data "terraform_remote_state" "storage" {
    backend = "s3"
    config = {
        bucket         = "dev-terraform-state-bucket-${data.aws_caller_identity.current.account_id}"
        key            = "env/dev/storage/terraform.tfstate"
        region         = var.region
        encrypt        = true
    }
}

# Call the compute module using networking and storage outputs
module "compute" {
    source = "../../../modules/compute"

    region                    = var.region
    env                       = var.env
    tags                      = var.tags
    email                     = var.email
    
    # Networking linkages
    private_vpc_id            = data.terraform_remote_state.networking.outputs.private_vpc_id
    public_vpc_id             = data.terraform_remote_state.networking.outputs.public_vpc_id
    public_alb_subnet_ids     = data.terraform_remote_state.networking.outputs.public_subnet_ids
    private_lambda_subnet_ids = data.terraform_remote_state.networking.outputs.private_subnet_ids
    
    # Storage linkages (dynamically pulled from remote state!)
    aurora_proxy_endpoint     = data.terraform_remote_state.storage.outputs.rds_proxy_endpoint
    rds_proxy_sg_id           = data.terraform_remote_state.storage.outputs.rds_proxy_security_group_id
}