resource "aws_ecs_cluster" "monitoring" {
    name = "${var.env}-monitoring-cluster"
}

resource "aws_cloudwatch_log_group" "monitoring_logs" {
    name = "/ecs/${var.env}-monitoring"
    retention_in_days = 7
}

resource "aws_ecs_task_definition" "monitoring_stack" {
    family = "${var.env}-monitoring"
    network_mode = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu = 1024
    memory = 2048

    execution_role_arn = aws_iam_role.ecs_execution_role.arn
    task_role_arn = aws_iam_role.ecs_task_role.arn
    
    container_definitions = jsonencode([
        {
            name = "grafana"
            image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.env}-grafana:latest"
            essential = true
            portMappings = [{containerPort = 3000, hostPort = 3000}]
            logConfiguration = {
                logDriver = "awslogs"
                options = {
                    "awslogs-group" = aws_cloudwatch_log_group.monitoring_logs.name
                    "awslogs-region" = var.region
                    "awslogs-stream-prefix" = "grafana"
                }
            }
        },
        {
            name = "prometheus"
            image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.env}-prometheus:latest"
            essential = true
            portMappings = [{containerPort = 9090, hostPort = 9090}]
            logConfiguration = {
                logDriver = "awslogs"
                options = {
                    "awslogs-group" = aws_cloudwatch_log_group.monitoring_logs.name
                    "awslogs-region" = var.region
                    "awslogs-stream-prefix" = "prometheus"
                }
            }
        },
        {
            name = "mysqld-exporter"
            image = "prom/mysqld-exporter:latest"
            essential = true
            portMappings = [{containerPort = 9104, hostPort = 9104}]
            # We pass the credentials directly via environment variables so the container can log in
            environment = [
                {
                    name = "DATA_SOURCE_NAME"
                    value = "${var.db_username}:${var.db_password}@(${var.db_proxy_endpoint}:3306)/"
                }
            ]
            logConfiguration = { logDriver = "awslogs", options = { "awslogs-group" = aws_cloudwatch_log_group.monitoring_logs.name, "awslogs-region" = var.region, "awslogs-stream-prefix" = "mysql-exporter" } }
        },
        {
            name = "yace-exporter"
            image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.env}-yace:latest"
            essential = true
            portMappings = [{containerPort = 5000, hostPort = 5000}]
            logConfiguration = { 
                logDriver = "awslogs", 
                options = { 
                    "awslogs-group" = aws_cloudwatch_log_group.monitoring_logs.name,
                    "awslogs-region" = var.region,
                    "awslogs-stream-prefix" = "yace"
                } 
            }
        }
    ])
}

resource "aws_ecs_service" "monitoring_ecs" {
    name = "${var.env}-monitoring-ecs"
    cluster = aws_ecs_cluster.monitoring.id
    task_definition = aws_ecs_task_definition.monitoring_stack.arn
    launch_type = "FARGATE"
    desired_count = 1

    network_configuration {
        subnets = var.private_subnet_ids
        security_groups = [aws_security_group.monitoring_stack_sg.id]
        assign_public_ip = false
    }
}