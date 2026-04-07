data "archive_file" "soar_zip"{
    type = "zip"
    source_dir = "${path.module}/lambda_src"
    output_path = "${path.module}/soar.zip"
}

resource "aws_lambda_function" "soar_responder"{
    filename = data.archive_file.soar_zip.output_path
    source_code_hash = data.archive_file.soar_zip.output_base64sha256
    function_name = "soar-responder"
    role = "${aws_iam_role.soar_lambda_role.arn}"
    handler = "soar_responder.lambda_handler"
    runtime = "python3.10"
    timeout = 10

    environment {
        variables = {
            WAF_IP_SET_NAME = var.waf_ip_blacklist_name
            WAF_IP_SET_ID = var.waf_ip_blacklist_id
            WAF_SCOPE = "REGIONAL"
        }
    }
}

resource "aws_lambda_permission" "allow_sns"{
    statement_id = "allow_sns"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.soar_responder.function_name
    principal = "sns.amazonaws.com"
    source_arn = aws_sns_topic.sns.arn
}

resource "aws_iam_role" "soar_lambda_role" {
    name = "soar_lambda_execution_role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
            Action = "sts:AssumeRole",
            Effect = "Allow",
            Principal = { Service = "lambda.amazonaws.com" }
        }]
    })
}

# Give the Lambda permission to write logs AND update the WAF IP Set
resource "aws_iam_role_policy" "soar_waf_policy" {
    name = "soar_waf_update_policy"
    role = aws_iam_role.soar_lambda_role.id
    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Action = [
                    "wafv2:GetIPSet",
                    "wafv2:UpdateIPSet"
                ],
                Resource = var.waf_ip_blacklist_arn
            },
            {
                Effect = "Allow",
                Action = [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ],
                Resource = "arn:aws:logs:*:*:*"
            }
        ]
    })
}