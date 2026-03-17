resource "aws_security_group" "aurora_db_sg" {
    name = "${var.env}-aurora-sg"
    vpc_id = var.private_vpc_id
    description = "Security group for Aurora RDS"

    ingress {
        description = "MySQL/Aurora"
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        security_groups = [aws_security_group.rds_proxy_sg.id]
    }
}

resource "aws_security_group" "rds_proxy_sg" {
    name = "${var.env}-rds-proxy-sg"
    vpc_id = var.private_vpc_id
    description = "Allow Lambda functions to access Aurora RDS Proxy"

    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = [var.private_vpc_cidr]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
}
