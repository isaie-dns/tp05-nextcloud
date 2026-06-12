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

## Inputs

| Variable | Type | Description |
|---|---|---|
| `project_name` | `string` | Préfixe de nommage (ex: `kolab`) |
| `environment` | `string` | Environnement (ex: `dev`) |
| `vpc_id` | `string` | ID du VPC (fourni par module networking) |
| `vpc_cidr` | `string` | CIDR du VPC (fourni par module networking) |
| `allowed_admin_cidr` | `string` | CIDR admin, défaut `0.0.0.0/0` |

## Outputs

| Output | Description |
|---|---|
| `alb_security_group_id` | SG ID pour l'ALB → consommé par module compute |
| `app_security_group_id` | SG ID pour les EC2 → consommé par module compute |
| `db_security_group_id` | SG ID pour RDS → consommé par module data |
| `kms_key_id` | ID de la CMK |
| `kms_key_arn` | ARN de la CMK → consommé par module data |
| `app_instance_profile_name` | Nom de l'instance profile → consommé par module compute |
| `app_iam_role_arn` | ARN du rôle IAM app |
| `app_iam_role_name` | Nom du rôle IAM app → policy S3 dans envs/dev |
| `db_password_secret_arn` | ARN secret DB → consommé par modules data + compute |
| `admin_password_secret_arn` | ARN secret admin → consommé par module compute |

## Sécurité

- Règles SG en ressources séparées (syntaxe AWS provider v5+)
- DB sans egress (isolation maximale)
- IAM policies scopées aux ARN précis (pas de wildcard sur `Resource`)
- KMS key policy : root account `kms:*` + rôle app `kms:Decrypt/DescribeKey/GenerateDataKey`
- `tfsec` : 0 erreur HIGH/CRITICAL
