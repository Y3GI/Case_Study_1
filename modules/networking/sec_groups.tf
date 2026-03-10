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
}

resource "aws_security_group" "monitoring_endpoint_sg" {
    for_each = var.private_subnet_cidrs

    name = "${var.env}-monitoring-endpoint-sg"
    description = "Security group of monitoring endpoint"
    vpc_id = aws_vpc.private.id

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = [aws_subnet.private[each.key].id]
    }
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
}