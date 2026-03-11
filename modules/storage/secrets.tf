resource "random_password" "aurora_db_password" {
    length = 16
    special = true
    override_special = "!@#$%^&*()_+-="
}

resource "aws_secretsmanager_secret" "aurora_db_secret" {
    name_prefix = "${var.env}-aurora-db-secret-"
    description = "Secret for Aurora RDS database credentials"

    recovery_window_in_days = 0

    tags = merge(var.tags, {
        Name = "${var.env}-aurora-db-secret"
    })
}

resource "aws_secretsmanager_secret_version" "aurora_db_secret_version" {
    secret_id = aws_secretsmanager_secret.aurora_db_secret.id
    secret_string = jsonencode({
        username = "admin"
        password = random_password.aurora_db_password.result
        engine = "mysql"
        host = aws_rds_cluster.aurora_rds.endpoint
        port = 3306
        dbClusterIdentifier = aws_rds_cluster.aurora_rds.cluster_identifier
    })
}