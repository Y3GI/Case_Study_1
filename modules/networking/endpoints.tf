resource "aws_ec2_client_vpn_endpoint" "vpn" {
    description = "${var.env}-VPN-Endpoint"
    server_certificate_arn = var.server_cert_arn
    client_cidr_block = var.vpn_cidr_block
    split_tunnel = true

    authentication_options {
        type = "certificate-authentication"
        root_certificate_chain_arn = var.client_cert_arn
    }

    connection_log_options {
        enabled = false 
    }

    tags = merge(var.tags, {
        Name = "${var.env}-vpn-endpoint"
    })
}

resource "aws_ec2_client_vpn_network_association" "main" {
    client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
    subnet_id = aws_subnet.private[keys(aws_subnet.private)[0]].id
}

#DB secrets endpoint for Aurora RDS
resource "aws_vpc_endpoint" "secretsmanager" {
    vpc_id = aws_vpc.private.id
    service_name = "com.amazonaws.${var.region}.secretsmanager"
    vpc_endpoint_type = "Interface"
    subnet_ids = [aws_subnet.private["db_subnet1"].id, aws_subnet.private["db_subnet2"].id]
    security_group_ids = [aws_security_group.rds_endpoint.id]
    private_dns_enabled = true
}

#Monitoring endpoints
resource "aws_vpc_endpoint" "ecr_api" {
    vpc_id = aws_vpc.private.id
    service_name = "com.amazonaws.${var.region}.ecr.api"
    vpc_endpoint_type = "Interface"
    subnet_ids = values({for s in aws_subnet.private : s.availability_zone => s.id})
    security_group_ids = [aws_security_group.monitoring_endpoint_sg.id]
    private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecr_dkr" {
    vpc_id = aws_vpc.private.id
    service_name = "com.amazonaws.${var.region}.ecr.dkr"
    vpc_endpoint_type = "Interface"
    subnet_ids = values({for s in aws_subnet.private : s.availability_zone => s.id})
    security_group_ids = [aws_security_group.monitoring_endpoint_sg.id]
    private_dns_enabled = true
}

resource "aws_vpc_endpoint" "cloudwatch_logs" {
    vpc_id = aws_vpc.private.id
    service_name = "com.amazonaws.${var.region}.logs"
    vpc_endpoint_type = "Interface"
    subnet_ids = values({for s in aws_subnet.private : s.availability_zone =>s.id})
    security_group_ids = [aws_security_group.monitoring_endpoint_sg.id]
    private_dns_enabled = true
}

resource "aws_vpc_endpoint" "s3"{
    vpc_id = aws_vpc.private.id
    service_name =  "com.amazonaws.${var.region}.s3"
    vpc_endpoint_type = "Gateway"
    route_table_ids = [aws_route_table.private.id]
}