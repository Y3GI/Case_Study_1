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

resource "aws_ec2_client_vpn_authorization_association" "main" {
    client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
    subnet_id = aws_subnet.private[keys(aws_subnet.private)[0]].id
    security_groups = []
}

#DB SOURCE endpoint

resource "aws_vpc_endpoint" "db_source" {
    vpc_id = aws_vpc.private.id
    service_name = "com.amazonaws.${var.region}.dynamodb"
    vpc_endpoint_type = "Gateway"
    route_table_ids = [aws_route_table.private.id]

    tags = merge(var.tags, {
        Name = "${var.env}-db-source-endpoint"
    })
}