data "aws_caller_identity" "current" {}

data "aws_kms_alias" "secretsmanager_key" {
    name = "alias/aws/secretsmanager"
}

resource "aws_iam_role" "rds_proxy_role" {
    name = "${var.env}-rds-proxy-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "rds.amazonaws.com"
            }
        }]
    })
}

resource "aws_iam_role_policy" "rds_proxy_secrets_policy" {
    name = "${var.env}-rds-proxy-secrets-policy"
    role = aws_iam_role.rds_proxy_role.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                # Permission to fetch the secret
                Action = [
                    "secretsmanager:GetSecretValue"
                ]
                Effect   = "Allow"
                Resource = aws_secretsmanager_secret.aurora_db_secret.arn
            },
            {
                # Permission to decrypt the secret
                Action = [
                    "kms:Decrypt"
                ]
                Effect   = "Allow"
                # Change the resource line inside your KMS statement to this:
                resources = [aws_secretsmanager_secret.aurora_db_secret.kms_key_id]
                Condition = {
                    StringEquals = {
                        "kms:ViaService" = "secretsmanager.${var.region}.amazonaws.com"
                    }
                }
            }
        ]
    })
}