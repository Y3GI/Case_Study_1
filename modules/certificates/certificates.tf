resource "aws_acm_certificate" "server" {
    private_key = file("${path.module}/certs/server/server.key")
    certificate_body = file("${path.module}/certs/server/server.crt")
    certificate_chain = file("${path.module}/certs/ca/ca.crt")

    tags = merge(var.tags, {
        Name = "${var.env}-server-certificate"
    })
}

resource "aws_acm_certificate" "client" {
    private_key = file("${path.module}/certs/client/client.key")
    certificate_body = file("${path.module}/certs/client/client.crt")
    certificate_chain = file("${path.module}/certs/ca/ca.crt")

    tags = merge(var.tags, {
        Name = "${var.env}-client-certificate"
    })
}