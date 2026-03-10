#Lambda security group allowing outbound access to Aurora RDS Proxy
resource "aws_security_group" "lambda_sg" {
    name = "${var.env}-lambda-sg"
    description = "Security group for Lambda functions"
    vpc_id = var.private_vpc_id

    egress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        security_groups = [var.rds_proxy_sg_id]
    }
}

#ALB security groups
resource "aws_security_group" "alb_sg" {
    name = "${var.env}-alb-sg"
    description = "Security group for ALB"
    vpc_id = var.public_vpc_id

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}