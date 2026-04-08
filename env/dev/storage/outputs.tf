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

output "rds_cluster_master_username" {
    description = "Aurora RDS master username"
    value       = module.storage.rds_cluster_master_username
}

output "rds_cluster_master_password" {
    description = "RDS Proxy password"
    value       = module.storage.rds_cluster_master_password
    sensitive   = true
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

output "ecr_loki_repository_url" {
    description = "Prometheus ECR repository URL"
    value       = module.storage.ecr_loki_repository_url
}

output "ecr_promtail_repository_url" {
    description = "Prometheus ECR repository URL"
    value       = module.storage.ecr_promtail_repository_url
}

output "ecr_mysql_exporter_repository_url"{
    description = "Matrix exporter ECR repository URL"
    value       = module.storage.ecr_mysql_exporter_repository_url
}
