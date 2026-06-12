output "role_arn" {
  description = "ARN du role IAM a renseigner dans role-to-assume du workflow GitHub Actions."
  value       = aws_iam_role.github_actions.arn
}

output "oidc_provider_arn" {
  description = "ARN du provider OIDC GitHub."
  value       = aws_iam_openid_connect_provider.github.arn
}
