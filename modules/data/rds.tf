# =============================================================================
# modules/data/rds.tf
# ROLE 4 — Data Engineer (Corrigé par le Platform Lead pour éviter les collisions)
# =============================================================================

# Lecture du mot de passe DB depuis Secrets Manager (créé par le Rôle 5)
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = var.db_password_secret_arn
}

# DB Subnet Group : RDS a besoin d'au moins 2 subnets sur 2 AZ
resource "aws_db_subnet_group" "nextcloud" {
  name       = "${local.name_prefix}-db-subnets"
  subnet_ids = values(var.private_db_subnet_ids)

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-db-subnets"
  })
}

# Parameter Group : paramètres PostgreSQL personnalisés (Nom rendu unique pour le TP)
resource "aws_db_parameter_group" "nextcloud" {
  name   = "${local.name_prefix}-pg16-theo" # <- Suffixe unique ajouté pour éviter le DBParameterGroupAlreadyExists
  family = "postgres16"

  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }

  parameter {
    name  = "log_statement"
    value = "ddl"
  }

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-pg16-params"
  })
}

# Instance RDS PostgreSQL 16 Multi-AZ chiffrée KMS
resource "aws_db_instance" "nextcloud" {
  identifier = "${local.name_prefix}-nextcloud"

  engine         = "postgres"
  engine_version = var.db_engine_version

  instance_class        = var.db_instance_class
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id            = var.kms_key_arn

  db_name  = "nextcloud"
  username = "nextcloud"
  password = data.aws_secretsmanager_secret_version.db_password.secret_string

  db_subnet_group_name   = aws_db_subnet_group.nextcloud.name
  vpc_security_group_ids = [var.db_security_group_id]
  publicly_accessible    = false
  port                   = 5432

  multi_az                = true
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  auto_minor_version_upgrade = true
  apply_immediately          = false

  enabled_cloudwatch_logs_exports     = ["postgresql", "upgrade"]
  performance_insights_enabled        = true
  performance_insights_kms_key_id     = var.kms_key_arn
  iam_database_authentication_enabled = true

  parameter_group_name = aws_db_parameter_group.nextcloud.name

  deletion_protection      = false # TP only — true en prod
  skip_final_snapshot      = true  # TP only — false en prod
  delete_automated_backups = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-nextcloud-rds"
  })

  lifecycle {
    ignore_changes = [password]
  }
}
