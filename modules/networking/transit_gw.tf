resource "aws_ec2_transit_gateway" "main" {
    description = "${var.env} Transit Gateway"

    default_route_table_association = "enable"
    default_route_table_propagation = "enable"
    dns_support = "enable"
    vpn_ecmp_support = "enable"

    tags = merge(var.tags, {
        Name = "${var.env}-transit-gateway"
    })
}

resource "aws_ec2_transit_gateway_vpc_attachment" "public" {
    transit_gateway_id = aws_ec2_transit_gateway.main.id
    vpc_id             = aws_vpc.public.id
    subnet_ids         = [for s in aws_subnet.public : s.id]

    tags = merge(var.tags, {
        Name = "${var.env}-transit-gateway-vpc-attachment-public"
    })
}

resource "aws_ec2_transit_gateway_vpc_attachment" "private" {
    transit_gateway_id = aws_ec2_transit_gateway.main.id
    vpc_id             = aws_vpc.private.id
    subnet_ids         = [aws_subnet.private["db_subnet1"].id, aws_subnet.private["db_subnet2"].id]

    tags = merge(var.tags, {
        Name = "${var.env}-transit-gateway-vpc-attachment-private"
    })
}

resource "aws_route" "tgw_public_to_private" {
    route_table_id = aws_route_table.public.id
    destination_cidr_block = var.private_vpc_cidr
    transit_gateway_id = aws_ec2_transit_gateway.main.id
    depends_on = [
        aws_ec2_transit_gateway_vpc_attachment.public,
        aws_ec2_transit_gateway_vpc_attachment.private
        ]
}

resource "aws_route" "tgw_private_to_public" {
    route_table_id = aws_route_table.private.id
    destination_cidr_block = var.public_vpc_cidr
    transit_gateway_id = aws_ec2_transit_gateway.main.id
    depends_on = [
        aws_ec2_transit_gateway_vpc_attachment.public,
        aws_ec2_transit_gateway_vpc_attachment.private
        ]
}