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
