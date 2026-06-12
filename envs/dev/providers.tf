# =============================================================================
# envs/dev/providers.tf
# Déclaration du provider AWS avec injection automatique des Tags FinOps & Owners
# =============================================================================

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "formation"

  # Centralisation des tags globaux : s'applique à TOUTES les ressources créées
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Team        = "Group_1_Lille"
      Owner       = "Theo-PlatformLead" # Preuve de ton rôle pour le formateur
    }
  }
}
