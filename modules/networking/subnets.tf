resource "aws_subnet" "public" {
    for_each = var.public_subnet_cidrs

    vpc_id = aws_vpc.public.id
    cidr_block = each.value.cidr_block
    availability_zone = each.value.az
    map_public_ip_on_launch = true

    tags = merge(var.tags, {
        Name = "${var.env}-public-subnet-${each.value.az}"
    })
}

resource "aws_subnet" "private" {
    for_each = var.private_subnet_cidrs

    vpc_id = aws_vpc.private.id
    cidr_block = each.value.cidr_block
    availability_zone = each.value.az

    tags = merge(var.tags, {
        Name = "${var.env}-private-subnet-${each.value.az}"
    })
}

resource "aws_db_subnet_group" "aurora_db_subnet_group" {
    name = "${var.env}-aurora-db-subnet-group"
    subnet_ids = [aws_subnet.private["db_subnet1"].id, aws_subnet.private["db_subnet2"].id]

    tags = merge(var.tags, {
        Name = "${var.env}-aurora-db-subnet-group"
    })
}