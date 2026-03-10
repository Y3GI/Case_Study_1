output "server_certificate_arn" {
  description = "The ARN of the server certificate"
  value       = aws_acm_certificate.server.arn
}

output "server_certificate_id" {
  description = "The ID of the server certificate"
  value       = aws_acm_certificate.server.id
}

output "client_certificate_arn" {
  description = "The ARN of the client certificate"
  value       = aws_acm_certificate.client.arn
}

output "client_certificate_id" {
  description = "The ID of the client certificate"
  value       = aws_acm_certificate.client.id
}
