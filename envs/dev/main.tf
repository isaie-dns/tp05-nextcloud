# =============================================================================
# envs/dev/main.tf
# ROLE 1 — Platform Lead (Orchestrateur)
# Assemblage final des modules métiers en cassant les dépendances cycliques
# =============================================================================

# 1. Réseau (Géré par le Rôle 2)
module "networking" {
  source = "../../modules/networking"

  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = "10.30.0.0/16"
  azs          = ["eu-west-3a", "eu-west-3b"]
}

# 2. Sécurité (Géré par le Rôle 5)
module "security" {
  source = "../../modules/security"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.networking.vpc_id
  vpc_cidr           = module.networking.vpc_cidr
  allowed_admin_cidr = var.allowed_admin_cidr

  # Références S3 injectées en late-binding pour la configuration des clés KMS
  s3_primary_bucket_arn = module.data.s3_primary_bucket_arn
  s3_logs_bucket_arn    = module.data.s3_logs_bucket_arn
}

# 3. Données (Géré par le Rôle 4)
module "data" {
  source = "../../modules/data"

  project_name = var.project_name
  environment  = var.environment

  vpc_id                 = module.networking.vpc_id
  private_db_subnet_ids  = module.networking.private_db_subnet_ids
  db_security_group_id   = module.security.db_security_group_id
  kms_key_arn            = module.security.kms_key_arn
  db_password_secret_arn = module.security.db_password_secret_arn
}

# -----------------------------------------------------------------------------
# Policy IAM S3 isolée au niveau de l'orchestration globale
# Permet d'éviter la dépendance circulaire directe entre Security et Data.
# -----------------------------------------------------------------------------
resource "aws_iam_role_policy" "app_s3_scoped" {
  name = "${var.project_name}-${var.environment}-app-s3-scoped"
  role = module.security.app_iam_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ManageNextcloudObjects"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:GetObjectVersion",
          "s3:AbortMultipartUpload"
        ]
        Resource = "${module.data.s3_primary_bucket_arn}/*"
      },
      {
        Sid    = "ListNextcloudBucket"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:ListBucketMultipartUploads"
        ]
        Resource = module.data.s3_primary_bucket_arn
      }
    ]
  })
}

# 4. Calcul / Application Nextcloud (Géré par le Rôle 3)
module "compute" {
  source = "../../modules/compute"

  project_name = var.project_name
  environment  = var.environment

  vpc_id                 = module.networking.vpc_id
  public_subnet_ids      = module.networking.public_subnet_ids
  private_app_subnet_ids = module.networking.private_app_subnet_ids

  alb_security_group_id     = module.security.alb_security_group_id
  app_security_group_id     = module.security.app_security_group_id
  app_instance_profile_name = module.security.app_instance_profile_name
  db_password_secret_arn    = module.security.db_password_secret_arn
  admin_password_secret_arn = module.security.admin_password_secret_arn

  db_endpoint            = module.data.db_endpoint
  db_name                = module.data.db_name
  db_username            = module.data.db_username
  s3_primary_bucket_name = module.data.s3_primary_bucket_name
  s3_logs_bucket_name    = module.data.s3_logs_bucket_name

  # L'AutoScaling Group attend que les droits d'accès S3 soient rattachés au rôle
  depends_on = [
    aws_iam_role_policy.app_s3_scoped
  ]
}
