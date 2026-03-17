resource "aws_iam_role" "lambda_exec_role" {
    name = "${var.env}-lambda-exec-role"

    assume_role_policy = jsonencode ({
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "lambda.amazonaws.com"
            }
        }]
    })

    tags = merge(var.tags, {
        Name = "${var.env}-lambda-exec-role"
    })
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
    role = aws_iam_role.lambda_exec_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}