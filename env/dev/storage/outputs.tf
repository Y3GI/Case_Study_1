# Storage outputs from the module
output "rds_cluster_endpoint" {
    description = "Aurora RDS cluster endpoint"
    value       = module.storage.rds_cluster_endpoint
    sensitive   = true
}

output "rds_cluster_reader_endpoint" {
    description = "Aurora RDS reader endpoint"
    value       = module.storage.rds_cluster_reader_endpoint
}

output "rds_proxy_endpoint" {
    description = "RDS Proxy endpoint"
    value       = module.storage.rds_proxy_endpoint
}

output "aurora_db_secret_arn" {
    description = "Aurora DB secret ARN"
    value       = module.storage.aurora_db_secret_arn
    sensitive   = true
}

output "aurora_db_secret_id" {
    description = "Aurora DB secret ID"
    value       = module.storage.aurora_db_secret_id
}

output "rds_proxy_security_group_id" {
    description = "RDS Proxy security group ID"
    value       = module.storage.rds_proxy_security_group_id
}

output "aurora_db_security_group_id" {
    description = "Aurora DB security group ID"
    value       = module.storage.aurora_db_security_group_id
}

output "ecr_grafana_repository_url" {
    description = "Grafana ECR repository URL"
    value       = module.storage.ecr_grafana_repository_url
}

output "ecr_prometheus_repository_url" {
    description = "Prometheus ECR repository URL"
    value       = module.storage.ecr_prometheus_repository_url
}

output "ecr_yace_repository_url" {
    description = "yace ECR repository URL"
    value       = module.storage.ecr_yace_repository_url
}

output "ecr_matrix_exporter_repository_url"{
    description = "Matrix exporter ECR repository URL"
    value       = module.storage.ecr_matix_exporter_repository_url
}
