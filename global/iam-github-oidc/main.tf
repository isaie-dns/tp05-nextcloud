# =============================================================================
# global/iam-github-oidc/main.tf
# Provider OIDC GitHub + role IAM assumable par GitHub Actions.
# Permet un terraform plan sans aucun secret stocke dans GitHub.
# =============================================================================

# Provider OIDC GitHub - un seul par compte AWS
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = {
    Name      = "github-actions-oidc"
    ManagedBy = "Terraform"
  }
}

# Role assumable par le workflow du repo <org>/<repo> uniquement
resource "aws_iam_role" "github_actions" {
  name = "kolab-github-actions-tf-plan"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          # Scoper le trust au repo exact pour eviter l abus cross-repo
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:*"
        }
      }
    }]
  })

  tags = {
    Name      = "kolab-github-actions-tf-plan"
    ManagedBy = "Terraform"
  }
}

# ReadOnlyAccess pour terraform plan (pas d apply en CI)
resource "aws_iam_role_policy_attachment" "read_only" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
