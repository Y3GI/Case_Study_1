output "rds_cluster_id" {
  description = "The ID of the RDS Aurora cluster"
  value       = aws_rds_cluster.aurora_rds.id
}

output "rds_cluster_arn" {
  description = "The ARN of the RDS Aurora cluster"
  value       = aws_rds_cluster.aurora_rds.arn
}

output "rds_cluster_endpoint" {
  description = "The cluster endpoint of the Aurora RDS cluster"
  value       = aws_rds_cluster.aurora_rds.endpoint
}

output "rds_cluster_reader_endpoint" {
  description = "The reader endpoint of the Aurora RDS cluster"
  value       = aws_rds_cluster.aurora_rds.reader_endpoint
}

output "rds_cluster_database_name" {
  description = "The database name of the Aurora RDS cluster"
  value       = aws_rds_cluster.aurora_rds.database_name
}

output "rds_cluster_master_username" {
  description = "The master username of the Aurora RDS cluster"
  value       = aws_rds_cluster.aurora_rds.master_username
}

output "rds_cluster_instances" {
  description = "Map of RDS cluster instance details"
  value       = { for k, v in aws_rds_cluster_instance.cluster_instance : k => v.id }
}

output "rds_proxy_endpoint" {
  description = "The endpoint of the RDS Proxy"
  value       = aws_db_proxy.rds_proxy.endpoint
}

output "rds_proxy_arn" {
  description = "The ARN of the RDS Proxy"
  value       = aws_db_proxy.rds_proxy.arn
}

output "rds_proxy_name" {
  description = "The name of the RDS Proxy"
  value       = aws_db_proxy.rds_proxy.name
}

output "rds_proxy_role_arn" {
  description = "The ARN of the RDS Proxy IAM role"
  value       = aws_iam_role.rds_proxy_role.arn
}

output "rds_proxy_target_group_name" {
  description = "The name of the RDS Proxy target group"
  value       = aws_db_proxy_default_target_group.proxy_target_group.name
}

output "aurora_db_secret_id" {
  description = "The ID of the Aurora DB secret"
  value       = aws_secretsmanager_secret.aurora_db_secret.id
}

output "aurora_db_secret_arn" {
  description = "The ARN of the Aurora DB secret"
  value       = aws_secretsmanager_secret.aurora_db_secret.arn
}

output "aurora_db_secret_version_id" {
  description = "The version ID of the Aurora DB secret"
  value       = aws_secretsmanager_secret_version.aurora_db_secret_version.version_id
}

output "ecr_grafana_repository_url" {
  description = "The URL of the Grafana ECR repository"
  value       = aws_ecr_repository.grafana.repository_url
}

output "ecr_grafana_repository_arn" {
  description = "The ARN of the Grafana ECR repository"
  value       = aws_ecr_repository.grafana.arn
}

output "ecr_prometheus_repository_url" {
  description = "The URL of the Prometheus ECR repository"
  value       = aws_ecr_repository.prometheus.repository_url
}

output "ecr_prometheus_repository_arn" {
  description = "The ARN of the Prometheus ECR repository"
  value       = aws_ecr_repository.prometheus.arn
}

output "ecr_yace_repository_url" {
  description = "The URL of the yace ECR repository"
  value       = aws_ecr_repository.yace.repository_url
}

output "ecr_yace_repository_arn" {
  description = "The ARN of the yace ECR repository"
  value       = aws_ecr_repository.yace.arn
}

output "ecr_mysql_exporter_repository_url" {
  description = "The URL of the matrix exporter ECR repository"
  value       = aws_ecr_repository.mysql_exporter.repository_url
}

output "ecr_mysql_exporter_repository_arn" {
  description = "The ARN of the matrix exporter ECR repository"
  value       = aws_ecr_repository.mysql_exporter.arn
}

output "aurora_db_security_group_id" {
  description = "The ID of the Aurora DB security group"
  value       = aws_security_group.aurora_db_sg.id
}

output "rds_proxy_security_group_id" {
  description = "The ID of the RDS Proxy security group"
  value       = aws_security_group.rds_proxy_sg.id
}
