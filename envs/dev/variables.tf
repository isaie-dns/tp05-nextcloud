# =============================================================================
# envs/dev/variables.tf
# Entrées globales de l'environnement de développement
# =============================================================================

variable "aws_region" {
  description = "Region AWS (impose : eu-west-3 pour RGPD)."
  type        = string
  default     = "eu-west-3"

  validation {
    condition     = var.aws_region == "eu-west-3"
    error_message = "La region doit être obligatoirement eu-west-3 (Paris) pour respecter les restrictions du compte de formation."
  }
}

variable "allowed_admin_cidr" {
  description = "CIDR IP autorise a atteindre l ALB en HTTPS (IP formateur)."
  type        = string

  validation {
    condition     = can(cidrhost(var.allowed_admin_cidr, 0)) && var.allowed_admin_cidr != "0.0.0.0/0"
    error_message = "Doit etre un CIDR IPv4 valide et different de 0.0.0.0/0 pour des raisons de securite."
  }
}

variable "project_name" {
  description = "Nom de projet pour le tagging."
  type        = string
  default     = "kolab"
}

variable "environment" {
  description = "Nom de l environnement."
  type        = string
  default     = "dev"
}
