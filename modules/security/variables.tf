# =============================================================================
# modules/security/variables.tf
# ROLE 5 — Security Engineer (Interfaces supervisées par le Platform Lead)
# =============================================================================

variable "project_name" {
  description = "Nom du projet (prefixe de nommage)."
  type        = string
}

variable "environment" {
  description = "Environnement (dev, staging, prod)."
  type        = string
}

variable "vpc_id" {
  description = "ID du VPC (fourni par le module networking)."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR du VPC (fourni par le module networking)."
  type        = string
}

variable "allowed_admin_cidr" {
  description = "CIDR autorise pour l acces admin (IP formateur)."
  type        = string
  default     = "0.0.0.0/0"
}

# -----------------------------------------------------------------------------
# Variables manquantes requises pour la configuration transversale des clés KMS
# -----------------------------------------------------------------------------
variable "s3_primary_bucket_arn" {
  description = "ARN du bucket S3 principal de Nextcloud, necessaire pour la policy de la cle KMS."
  type        = string
}

variable "s3_logs_bucket_arn" {
  description = "ARN du bucket S3 dedie aux logs d'acces de l'ALB, necessaire pour la policy de la cle KMS."
  type        = string
}
