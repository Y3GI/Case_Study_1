resource "aws_ec2_client_vpn_authorization_rule" "main" {
    client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
    target_network_cidr = var.private_vpc_cidr
    authorize_all_groups = true
}