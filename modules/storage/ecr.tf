resource "aws_ecr_repository" "grafana" {
    name = "${var.env}-grafana"
    image_tag_mutability = "MUTABLE"
    force_delete = true

    tags = merge(var.tags, {
        Name = "${var.env}-grafana"
    })
}

resource "aws_ecr_repository" "prometheus" {
    name = "${var.env}-prometheus"
    image_tag_mutability = "MUTABLE"
    force_delete = true

    tags = merge(var.tags, {
        Name = "${var.env}-prometheus"
    })
}

resource "aws_ecr_repository" "loki" {
    name = "${var.env}-loki"
    image_tag_mutability = "MUTABLE"
    force_delete = true

    tags = merge(var.tags, {
        Name = "${var.env}-loki"
    })
}

resource "aws_ecr_repository" "alloy" {
    name = "${var.env}-alloy"
    image_tag_mutability = "MUTABLE"
    force_delete = true

    tags = merge(var.tags, {
        Name = "${var.env}-alloy"
    })
}

resource "aws_ecr_repository" "mysql_exporter" {
    name = "${var.env}-mysql-exporter"
    image_tag_mutability = "MUTABLE"
    force_delete = true

    tags = merge(var.tags, {
        Name = "${var.env}-mysql-exporter"
    })
}