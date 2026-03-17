resource "aws_ecr_repository" "grafana" {
    name = "${var.env}-grafana"
    image_tag_mutability = "MUTABLE"
    force_delete = true
}

resource "aws_ecr_repository" "prometheus" {
    name = "${var.env}-prometheus"
    image_tag_mutability = "MUTABLE"
    force_delete = true
}

resource "aws_ecr_repository" "yace" {
    name = "${var.env}-yace"
    image_tag_mutability = "MUTABLE"
    force_delete = true
}

resource "aws_ecr_repository" "mysql_exporter" {
    name = "${var.env}-aurora-matrix-exporter"
    image_tag_mutability = "MUTABLE"
    force_delete = true
}