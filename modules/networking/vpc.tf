resource "aws_vpc" "private" {
    cidr_block = var.private_vpc_cidr
    enable_dns_support   = true
    enable_dns_hostnames = true

    tags = merge(var.tags, {
        Name = "${var.env}-private-vpc"
    })
}

resource "aws_vpc" "public" {
    cidr_block = var.public_vpc_cidr
    enable_dns_support   = true
    enable_dns_hostnames = true

    tags = merge(var.tags, {
        Name = "${var.env}-public-vpc"
    })
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.public.id

    tags = merge(var.tags, {
        Name = "${var.env}-internet-gateway"
    })
}