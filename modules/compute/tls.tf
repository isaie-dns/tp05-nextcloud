# 1. Clé privée RSA 2048 bits (générée en mémoire Terraform)
resource "tls_private_key" "self_signed" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# 2. Certificat X509 auto-signé, valide 2 ans
resource "tls_self_signed_cert" "alb" {
  private_key_pem = tls_private_key.self_signed.private_key_pem

  subject {
    common_name  = "${local.name_prefix}.kolab.local"
    organization = "Kolab Cabinet Avocats"
  }

  validity_period_hours = 17520 # 2 ans

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  dns_names = [
    "${local.name_prefix}.kolab.local",
    "*.elb.amazonaws.com",
    "*.eu-west-3.elb.amazonaws.com",
  ]
}

# 3. Import du cert dans ACM
resource "aws_acm_certificate" "self_signed" {
  private_key      = tls_private_key.self_signed.private_key_pem
  certificate_body = tls_self_signed_cert.alb.cert_pem

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb-cert"
  })

  lifecycle {
    create_before_destroy = true
  }
}