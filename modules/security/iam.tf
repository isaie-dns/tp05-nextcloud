# =============================================================================
# modules/security/iam.tf
# ROLE 5 — Security Engineer (Patch de contournement appliqué par le Platform Lead)
#
# =============================================================================

# 1. Récupération du rôle IAM pré-créé par le formateur (Pas de création = Pas de blocage)
data "aws_iam_role" "app" {
  name = "LabInstanceRole"
}

# 2. Récupération du profil d'instance pré-créé associé au rôle
data "aws_iam_instance_profile" "app" {
  name = "LabInstanceRole"
}

# 3. Injection de la politique Secrets Manager sur le rôle de formation existant
resource "aws_iam_role_policy" "app_secrets" {
  name = "${local.name_prefix}-app-secrets"
  role = data.aws_iam_role.app.name # Attachement direct sur le nom du rôle récupéré

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["secretsmanager:GetSecretValue"]
      Resource = [
        aws_secretsmanager_secret.db_password.arn,
        aws_secretsmanager_secret.admin_password.arn
      ]
    }]
  })
}

# 4. Injection de la politique KMS sur le rôle de formation existant
resource "aws_iam_role_policy" "app_kms" {
  name = "${local.name_prefix}-app-kms"
  role = data.aws_iam_role.app.name # Attachement direct sur le nom du rôle récupéré

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "kms:Decrypt",
        "kms:DescribeKey",
        "kms:GenerateDataKey"
      ]
      Resource = [aws_kms_key.main.arn]
    }]
  })
}
