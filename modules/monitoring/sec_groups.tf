resource "aws_security_group" "monitoring_stack_sg" {
    name = "${var.env}-monitoring-sg"
    vpc_id = var.private_vpc_id
    description = "Security group for monitoring stack"

    ingress {
        from_port = 3000
        to_port = 3000
        protocol = "tcp"
        security_groups = [var.vpn_sg_id]
    }

    ingress {
        from_port = 9090
        to_port = 9090
        protocol = "tcp"
        security_groups = [var.vpn_sg_id]
    }

    ingress {
        from_port = 3100
        to_port = 3100
        protocol = "tcp"
        security_groups = [var.vpn_sg_id]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        security_groups = [var.vpn_sg_id]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [var.private_vpc_cidr]
    }
}