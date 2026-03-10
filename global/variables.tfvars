# Global variables values - single source of truth
region = "eu-central-1"

tags = {
    Environment = "Development"
    Owner       = "Boyan Stefanov"
    Project     = "Case Study 1"
}

env = "dev"

email = "547283@student.fontys.nl"

# Private/Public VPC IDs - override these with actual AWS IDs
private_vpc_id = ""  # Set via remote state or environment
public_vpc_id  = ""  # Set via remote state or environment
