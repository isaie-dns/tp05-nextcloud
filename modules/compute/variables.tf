variable "vpc_id" {
  type        = string
  description = "ID du VPC (output du module networking)"
}

variable "public_subnet_ids" {
  type        = map(string)
  description = "Map AZ -> subnet_id public (pour l'ALB)"
}

variable "private_app_subnet_ids" {
  type        = map(string)
  description = "Map AZ -> subnet_id prive (pour l'ASG)"
}

variable "alb_security_group_id" {
  type        = string
  description = "SG de l'ALB (fourni par le module security)"
}

variable "app_security_group_id" {
  type        = string
  description = "SG des EC2 applicatives (fourni par le module security)"
}

variable "app_instance_profile_name" {
  type        = string
  description = "Instance profile IAM pour l'ASG (fourni par security)"
}

variable "db_endpoint" {
  type        = string
  description = "Hostname RDS (output du module data)"
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password_secret_arn" {
  type        = string
  description = "ARN du secret Secrets Manager contenant le mot de passe DB"
}

variable "admin_password_secret_arn" {
  type        = string
  description = "ARN du secret du mot de passe admin Nextcloud"
}

variable "s3_primary_bucket_name" {
  type        = string
  description = "Nom du bucket S3 primary storage Nextcloud"
}

variable "s3_logs_bucket_name" {
  type        = string
  description = "Nom du bucket S3 pour les access logs ALB"
}

variable "project_name" {
  type    = string
  default = "kolab"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "instance_type" {
  type        = string
  default     = "t3.small"
  description = "t3.small mini pour faire tourner Docker + Nextcloud confortablement"
variable "vpc_id" {
  type        = string
  description = "ID du VPC (output du module networking)"
}

variable "public_subnet_ids" {
  type        = map(string)
  description = "Map AZ -> subnet_id public (pour l'ALB)"
}

variable "private_app_subnet_ids" {
  type        = map(string)
  description = "Map AZ -> subnet_id prive (pour l'ASG)"
}

variable "alb_security_group_id" {
  type        = string
  description = "SG de l'ALB (fourni par le module security)"
}

variable "app_security_group_id" {
  type        = string
  description = "SG des EC2 applicatives (fourni par le module security)"
}

variable "app_instance_profile_name" {
  type        = string
  description = "Instance profile IAM pour l'ASG (fourni par security)"
}

variable "db_endpoint" {
  type        = string
  description = "Hostname RDS (output du module data)"
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password_secret_arn" {
  type        = string
  description = "ARN du secret Secrets Manager contenant le mot de passe DB"
}

variable "admin_password_secret_arn" {
  type        = string
  description = "ARN du secret du mot de passe admin Nextcloud"
}

variable "s3_primary_bucket_name" {
  type        = string
  description = "Nom du bucket S3 primary storage Nextcloud"
}

variable "s3_logs_bucket_name" {
  type        = string
  description = "Nom du bucket S3 pour les access logs ALB"
}

variable "project_name" {
  type    = string
  default = "kolab"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "instance_type" {
  type        = string
  default     = "t3.small"
  description = "t3.small mini pour faire tourner Docker + Nextcloud confortablement"
}