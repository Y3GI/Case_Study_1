output "github_actions_role_arn" {
    description = "github-actions-role-arn"
    value = aws_iam_role.github_actions.arn
}