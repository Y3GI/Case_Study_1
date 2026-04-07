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

data "terraform_remote_state" "networking" {
    backend = "s3"
    config = {
        bucket         = "dev-terraform-state-bucket-${data.aws_caller_identity.current.account_id}"
        key            = "env/dev/security/terraform.tfstate"
        region         = var.region
        encrypt        = true
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

data "terraform_remote_state" "certificates" {
    backend = "s3"
    config = {
        bucket         = "dev-terraform-state-bucket-${data.aws_caller_identity.current.account_id}"
        key            = "env/dev/certificates/terraform.tfstate"
        region         = var.region
        encrypt        = true
    }
}

data "terraform_remote_state" "soar" {
    backend = "s3"
    config = {
        bucket         = "dev-terraform-state-bucket-${data.aws_caller_identity.current.account_id}"
        key            = "env/dev/soar/terraform.tfstate"
        region         = var.region
        encrypt        = true
    }
}

data "terraform_remote_state" "monitoring" {
    backend = "s3"
    config = {
        bucket         = "dev-terraform-state-bucket-${data.aws_caller_identity.current.account_id}"
        key            = "env/dev/monitoring/terraform.tfstate"
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
    private_lambda_subnet_ids = data.terraform_remote_state.networking.outputs.lambda_subnet_ids
    
    # Storage linkages (dynamically pulled from remote state!)
    aurora_proxy_endpoint     = data.terraform_remote_state.storage.outputs.rds_proxy_endpoint
    aurora_username           = data.terraform_remote_state.storage.outputs.rds_cluster_master_username
    aurora_password           = data.terraform_remote_state.storage.outputs.rds_cluster_master_password
    rds_proxy_sg_id           = data.terraform_remote_state.storage.outputs.rds_proxy_security_group_id

    #Certificate for encryption
    alb_cert_arn              = data.terraform_remote_state.certificates.outputs.server_certificate_arn
    
    alb_logs_bucket           = data.terraform_remote_state.monitoring.outputs.alb_logs_bucket

    waf_arn                   = data.terraform_remote_state.security.outputs.waf_arn
}