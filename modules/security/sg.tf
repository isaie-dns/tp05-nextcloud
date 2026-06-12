# =============================================================================
# modules/security/sg.tf
# 3 Security Groups : alb (public), app (prive), db (prive-DB).
# Syntaxe v5+ : regles en ressources separees (pas de blocs ingress/egress inline).
# =============================================================================

#############################################
# SG ALB - accepte HTTPS et HTTP depuis Internet
#############################################
resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-alb"
  description = "SG pour l ALB public Nextcloud"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb"
  })
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb.id
  description       = "HTTPS from Internet"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  description       = "HTTP from Internet (redirect to HTTPS)"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb_all" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow all egress"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#############################################
# SG app - accepte uniquement depuis le SG ALB
#############################################
resource "aws_security_group" "app" {
  name        = "${local.name_prefix}-app"
  description = "SG pour les EC2 Nextcloud derriere l ALB"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-app"
  })
}

resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
  security_group_id            = aws_security_group.app.id
  description                  = "HTTP from ALB only"
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "app_all" {
  security_group_id = aws_security_group.app.id
  description       = "Allow all egress"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#############################################
# SG db - accepte uniquement depuis le SG app (PostgreSQL)
#############################################
resource "aws_security_group" "db" {
  name        = "${local.name_prefix}-db"
  description = "SG pour RDS PostgreSQL - acces depuis app uniquement"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-db"
  })
}

resource "aws_vpc_security_group_ingress_rule" "db_from_app" {
  security_group_id            = aws_security_group.db.id
  description                  = "PostgreSQL from app SG only"
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}