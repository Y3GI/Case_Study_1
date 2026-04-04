resource "aws_security_group" "vpn_access" {
    name        = "vpn-access-sg"
    description = "Security group for VPN endpoint"
    vpc_id      = aws_vpc.private.id

    # Allow VPN traffic out to the VPC
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = merge(var.tags, {
        Name = "${var.env}-vpn-access-sg"
    })
}

resource "aws_security_group" "monitoring_endpoint_sg" {

    name = "${var.env}-monitoring-endpoint-sg"
    description = "Security group of monitoring endpoint"
    vpc_id = aws_vpc.private.id

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = [var.private_vpc_cidr]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    tags = merge(var.tags, {
        Name = "${var.env}-monitoring-endpoint-sg"
    })
}

resource "aws_security_group" "rds_endpoint" {
    name = "${var.env}-rds-endpoint-sg"
    description = "Security group for RDS endpoint"
    vpc_id = aws_vpc.private.id

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = [var.private_subnet_cidrs["db_subnet1"].cidr_block, var.private_subnet_cidrs["db_subnet2"].cidr_block]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = merge(var.tags, {
        Name = "${var.env}-rds-endpoint-sg"
    })
}

resource "aws_security_group" "sns_endpoint_sg"{
    description = "Security group for SOAR endpoint"
    vpc_id = aws_vpc.private.id

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = [var.private_vpc_cidr]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = merge(var.tags, {
        Name = "${var.env}-sns-endpoint-sg"
    })
}