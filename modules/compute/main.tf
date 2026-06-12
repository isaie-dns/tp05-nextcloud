# -----------------------------------------------------------------------------
# modules/compute/main.tf
# Data sources + locals transversaux du module compute
# -----------------------------------------------------------------------------

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  public_subnet_ids_list      = values(var.public_subnet_ids)
  private_app_subnet_ids_list = values(var.private_app_subnet_ids)

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Module      = "compute"
    Owner       = "etudiant07"
  }
}

