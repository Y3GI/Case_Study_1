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

resource "aws_ecr_repository" "loki" {
    name = "${var.env}-loki"
    image_tag_mutability = "MUTABLE"
    force_delete = true
}