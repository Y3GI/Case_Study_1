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

resource "aws_eip" "nat" {
    domain = "vpc"

    tags = merge(var.tags, {
        Name = "${var.env}-nat-eip"
    })
}

resource "aws_nat_gateway" "main" {
    allocation_id = aws_eip.nat.id
    subnet_id     = aws_subnet.public[keys(aws_subnet.public)[0]].id

    tags = merge(var.tags, {
        Name = "${var.env}-nat-gateway"
    })
    depends_on = [ aws_internet_gateway.igw ]
}