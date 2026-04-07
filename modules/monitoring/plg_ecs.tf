data "aws_elb_service_account" "main" {}

data "aws_caller_identity" "current" {}

resource "aws_ecs_cluster" "monitoring" {
    name = "${var.env}-monitoring-cluster"

    tags = merge(var.tags, {
        Name = "${var.env}-monitoring-cluster"
    })
}

resource "aws_cloudwatch_log_group" "monitoring_logs" {
    name = "/ecs/${var.env}-monitoring"
    retention_in_days = 7

    tags = merge(var.tags, {
        Name = "${var.env}-monitoring-logs"
    })
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
            environment = [{ 
                name = "GF_ANALYTICS_CHECK_FOR_UPDATES", value = "false" 
            }]
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
            image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.env}-mysql-exporter:latest"
            essential = true
            portMappings = [{containerPort = 9104, hostPort = 9104}]
            
            entrypoint = ["sh", "-c"]
            
            command = [
                "echo '[client]' > /tmp/.my.cnf && echo 'user=${var.db_username}' >> /tmp/.my.cnf && echo 'password=${var.db_password}' >> /tmp/.my.cnf && echo 'host=${var.db_proxy_endpoint}' >> /tmp/.my.cnf && echo 'port=3306' >> /tmp/.my.cnf && exec /bin/mysqld_exporter --config.my-cnf=/tmp/.my.cnf"
            ]
            logConfiguration = { 
                logDriver = "awslogs", 
                options = { 
                    "awslogs-group" = aws_cloudwatch_log_group.monitoring_logs.name, 
                    "awslogs-region" = var.region, 
                    "awslogs-stream-prefix" = "mysql-exporter" 
                } 
            }
        }
    ])

    tags = merge(var.tags, {
        Name = "${var.env}-monitoring-stack"
    })
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

    tags = merge(var.tags, {
        Name = "${var.env}-monitoring-ecs"
    })
}

#ALB monitoring

resource "aws_s3_bucket" "alb_logs"{
    bucket = "${var.env}-alb-access-logs-${data.aws_caller_identity.current.account_id}"
    force_destroy = true

    tags = var.tags
}

resource "aws_s3_bucket_policy" "alb_logs_policy" {
    bucket = aws_s3_bucket.alb_logs.id
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Effect = "Allow"
            Principal = {
                AWS = data.aws_elb_service_account.main.arn
            }
            Action   = "s3:PutObject"
            Resource = "${aws_s3_bucket.alb_logs.arn}/AWSLogs/*"
        }
        ]
    })
}