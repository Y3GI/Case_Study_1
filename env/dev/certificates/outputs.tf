# Certificates outputs from the module
output "server_certificate_arn" {
    description = "Server certificate ARN"
    value       = module.certificates.server_certificate_arn
}

output "server_certificate_id" {
    description = "Server certificate ID"
    value       = module.certificates.server_certificate_id
}

output "client_certificate_arn" {
    description = "Client certificate ARN"
    value       = module.certificates.client_certificate_arn
}

output "client_certificate_id" {
    description = "Client certificate ID"
    value       = module.certificates.client_certificate_id
}
