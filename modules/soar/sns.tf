resource "aws_sns_topic" "sns" {
    tags = merge(var.tags, {
        Name = "${var.env}-grafana-alerts"
    })
}

resource "aws_sns_topic_subscription" "sns_lambda" {
    topic_arn = aws_sns_topic.sns.arn
    protocol = "lambda"
    endpoint = aws_lambda_function.soar_responder.arn
}

resource "aws_sns_topic_subscription" "sns_email" {
    topic_arn = aws_sns_topic.sns.arn
    protocol = "email"
    endpoint = var.email
}