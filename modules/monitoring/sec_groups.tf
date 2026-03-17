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
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = merge(var.tags, {
        Name = "${var.env}-monitoring-sg"
    })
}

resource "aws_security_group_rule" "monitoring_to_rds_proxy" {
    type                     = "ingress"
    from_port                = 3306
    to_port                  = 3306
    protocol                 = "tcp"
    security_group_id        = var.rds_proxy_sg_id 
    source_security_group_id = aws_security_group.monitoring_stack_sg.id
}