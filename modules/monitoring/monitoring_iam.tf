data "aws_caller_identity" "current" {}

resource "aws_iam_role" "ecs_execution_role" {
    name = "${var.env}-ecs-exec-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = { Service = "ecs-tasks.amazonaws.com" }
        }]
    })

    tags = merge(var.tags, {
        Name = "${var.env}-current-account"
    })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
    role = aws_iam_role.ecs_execution_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_role" {
    name = "${var.env}-ecs-task-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = { Service = "ecs-tasks.amazonaws.com" }
        }]
    })

    tags = merge(var.tags, {
        Name = "${var.env}-ecs-task-role"
    })
}

resource "aws_iam_role_policy_attachment" "ecs_task_cloudwatch_policy" {
    role = aws_iam_role.ecs_execution_role.id
    policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}

resource "aws_iam_role_policy" "ecs_task_monitoring_permissions" {
    name = "${var.env}-grafana-yace-policy"
    role = aws_iam_role.ecs_task_role.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "logs:DescribeLogGroups",
                    "logs:DescribeLogStreams",
                    "logs:FilterLogEvents",
                    "logs:GetLogEvents",
                    "logs:GetLogGroupFields",
                    "logs:StartQuery",
                    "logs:StopQuery",
                    "logs:GetQueryResults",
                    "logs:GetLogRecord"
                ]
                Resource = "*"
            },
            {
                Effect = "Allow"
                Action = [
                    "tag:GetResources"
                ]
                Resource = "*"
            },
            {
                Effect = "Allow"
                Action = [
                    "cloudwatch:ListMetrics",
                    "cloudwatch:GetMetricData",
                    "cloudwatch:GetMetricStatistics",
                    "cloudwatch:DescribeAlarms"
                ]
                Resource = "*"
            },
            {
                Effect = "Allow"
                Action = [
                    "sns:Publish"
                ]
                Resource = "*"
            }
        ]
    })
}