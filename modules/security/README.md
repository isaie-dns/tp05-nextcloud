# Module `security`

Centralise toute la sécurité de l'infrastructure Nextcloud : KMS CMK, Security Groups, Secrets Manager, IAM role + instance profile.

Créé par le **Rôle 5 — Security Engineer** lors du TP05.

## Contenu

| Ressource | Fichier | Description |
|---|---|---|
| `aws_kms_key` + `aws_kms_alias` | `kms.tf` | CMK avec rotation annuelle, chiffre S3 / RDS / Secrets |
| `aws_security_group` x3 | `sg.tf` | ALB (public 443/80), app (depuis ALB), db (depuis app 5432) |
| `aws_secretsmanager_secret` x2 | `secrets.tf` | db_password (24c) + admin_password (20c), chiffrés KMS |
| `aws_iam_role` + `aws_iam_instance_profile` | `iam.tf` | Role EC2 + policies scopées + SSM + CloudWatch |

## Sécurité

- Règles SG en ressources séparées (syntaxe AWS provider v5+)
- DB sans egress (isolation maximale)
- IAM policies scopées aux ARN précis (pas de wildcard sur `Resource`)
- KMS key policy : root account `kms:*` + rôle app `kms:Decrypt/DescribeKey/GenerateDataKey`
- `tfsec` : 0 erreur HIGH/CRITICAL

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
