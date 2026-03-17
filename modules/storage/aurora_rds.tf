resource "aws_rds_cluster" "aurora_rds" {
    cluster_identifier = "${var.env}-aurora-cluster"
    engine = "aurora-mysql"
    engine_version = "8.0.mysql_aurora.3.10.3"
    database_name = "aurora_db"
    master_username = "admin"
    master_password = random_password.aurora_db_password.result
    vpc_security_group_ids = [aws_security_group.aurora_db_sg.id]
    db_subnet_group_name = var.subnet_group_name
    storage_encrypted = false
    skip_final_snapshot = true
}

resource "aws_rds_cluster_instance" "cluster_instance" {
    for_each = var.aurora_instances

    identifier = "${var.env}-aurora-instance-${each.key}"
    cluster_identifier = aws_rds_cluster.aurora_rds.id
    instance_class = each.value.instance_class
    engine = aws_rds_cluster.aurora_rds.engine
    engine_version = aws_rds_cluster.aurora_rds.engine_version
    publicly_accessible = false
}

resource "aws_db_proxy" "rds_proxy" {
    name = "${var.env}-rds-proxy"
    debug_logging = false
    engine_family = "MYSQL"
    idle_client_timeout = 1800
    require_tls = true
    role_arn = aws_iam_role.rds_proxy_role.arn
    vpc_security_group_ids = [aws_security_group.rds_proxy_sg.id]
    vpc_subnet_ids = var.private_subnet_ids

    depends_on = [aws_rds_cluster_instance.cluster_instance]

    auth {
        auth_scheme = "SECRETS"
        description = "Use the secrets for the Aurora RDS Proxy"
        iam_auth = "DISABLED"
        secret_arn = aws_secretsmanager_secret.aurora_db_secret.arn
    }
}

resource "aws_db_proxy_default_target_group" "proxy_target_group" {
    db_proxy_name = aws_db_proxy.rds_proxy.name

    connection_pool_config {
        connection_borrow_timeout = 120
        max_connections_percent = 100
        max_idle_connections_percent = 50
    }
}

resource "aws_db_proxy_target" "rds_target" {
    db_cluster_identifier = aws_rds_cluster.aurora_rds.id
    db_proxy_name = aws_db_proxy.rds_proxy.name
    target_group_name = aws_db_proxy_default_target_group.proxy_target_group.name
}