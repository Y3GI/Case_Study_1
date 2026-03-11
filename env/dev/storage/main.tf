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

# Call the storage module using networking outputs
module "storage" {
    source = "../../../modules/storage"

    region                  = var.region
    env                     = var.env
    tags                    = var.tags
    email                   = var.email
    
    # We pull these IN because the networking module created them
    private_vpc_id          = data.terraform_remote_state.networking.outputs.private_vpc_id
    private_subnet_ids      = data.terraform_remote_state.networking.outputs.private_subnet_ids
    subnet_group_name       = data.terraform_remote_state.networking.outputs.db_subnet_group_name
    
    lambda_sg_id            = var.lambda_sg_id  
    aurora_instances        = var.aurora_instances
    
    # Notice: db_cluster_endpoint and aurora_cluster_endpoint are GONE!
}