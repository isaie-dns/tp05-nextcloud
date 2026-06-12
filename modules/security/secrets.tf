# =============================================================================
# modules/security/secrets.tf
# 2 secrets AWS Secrets Manager : mot de passe DB + mot de passe admin Nextcloud.
# =============================================================================

resource "random_password" "db" {
  length           = 24
  special          = false
  override_special = ""
}

resource "random_password" "admin" {
  length  = 20
  special = true
}

resource "aws_secretsmanager_secret" "db_password" {
  name                    = "${local.name_prefix}-db-password"
  kms_key_id              = aws_kms_key.main.arn
  recovery_window_in_days = 0

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-db-password"
  })
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db.result
}

resource "aws_secretsmanager_secret" "admin_password" {
  name                    = "${local.name_prefix}-admin-password"
  kms_key_id              = aws_kms_key.main.arn
  recovery_window_in_days = 0

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-admin-password"
  })
}

resource "aws_secretsmanager_secret_version" "admin_password" {
  secret_id     = aws_secretsmanager_secret.admin_password.id
  secret_string = random_password.admin.result
}