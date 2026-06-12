# =============================================================================
# modules/security/iam.tf
# IAM role + instance profile pour les EC2 Nextcloud.
# Policies scopees : Secrets Manager + KMS Decrypt.
# (La policy S3 est declaree dans envs/dev/main.tf pour eviter
#  la dependance circulaire entre les modules security et data.)
# =============================================================================

data "aws_iam_policy_document" "assume_ec2" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "app" {
  name                 = "${local.name_prefix}-app-role"
  permissions_boundary = "arn:aws:iam::039497794217:policy/formation-permissions-boundary-paris"
  assume_role_policy   = data.aws_iam_policy_document.assume_ec2.json

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-app-role"
  })
}

resource "aws_iam_role_policy" "app_secrets" {
  name = "${local.name_prefix}-app-secrets"
  role = aws_iam_role.app.id

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

resource "aws_iam_role_policy" "app_kms" {
  name = "${local.name_prefix}-app-kms"
  role = aws_iam_role.app.id

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

resource "aws_iam_role_policy_attachment" "app_ssm" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "app_cloudwatch" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "app" {
  name = "${local.name_prefix}-app-profile"
  role = aws_iam_role.app.name

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-app-profile"
  })
}
