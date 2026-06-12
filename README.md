# Infrastructure Nextcloud — Documentation Terraform
 
## Table des matières
 
- [Vue d'ensemble](#vue-densemble)
- [Module `networking`](#module-networking)
- [Module `security`](#module-security)
- [Module `data`](#module-data)
- [Module `compute`](#module-compute)
- [Root module (environnement `dev`)](#root-module-environnement-dev)
 
---
 
## Vue d'ensemble
 
L'infrastructure est découpée en 4 modules indépendants orchestrés par un root module :
 
| Module | Rôle |
|--------|------|
| `networking` | VPC, subnets, NAT, VPC endpoints |
| `security` | KMS, Security Groups, Secrets Manager, IAM |
| `data` | RDS PostgreSQL, S3 primary + logs |
| `compute` | ALB, ASG, Launch Template, certificat TLS |
 
---
 
## Module `networking`
 
VPC `10.30.0.0/16` avec 6 subnets sur 2 AZ, NAT single et 2 VPC endpoints.
 
### Inputs
 
| Nom | Type | Défaut | Requis |
|-----|------|--------|:------:|
| `project_name` | `string` | — | oui |
| `environment` | `string` | — | oui |
| `vpc_cidr` | `string` | `"10.30.0.0/16"` | non |
| `azs` | `list(string)` | `["eu-west-3a","eu-west-3b"]` | non |
 
### Outputs
 
| Nom | Description |
|-----|-------------|
| `vpc_id` | ID du VPC |
| `vpc_cidr` | CIDR du VPC |
| `public_subnet_ids` | Map AZ → subnet public |
| `private_app_subnet_ids` | Map AZ → subnet privé applicatif |
| `private_db_subnet_ids` | Map AZ → subnet privé DB |
| `nat_gateway_public_ip` | IP publique de la NAT Gateway |
| `vpc_endpoints_security_group_id` | SG des VPC endpoints |
 
### Usage
 
```hcl
module "networking" {
  source       = "../../modules/networking"
  project_name = "nextcloud"
  environment  = "dev"
}
```
 
---
 
## Module `security`
 
Centralise toute la sécurité de l'infrastructure : KMS CMK, Security Groups, Secrets Manager, IAM role + instance profile.
 
### Contenu
 
| Ressource | Fichier | Description |
|-----------|---------|-------------|
| `aws_kms_key` + `aws_kms_alias` | `kms.tf` | CMK avec rotation annuelle, chiffre S3 / RDS / Secrets |
| `aws_security_group` x3 | `sg.tf` | ALB (public 443/80), app (depuis ALB), db (depuis app 5432) |
| `aws_secretsmanager_secret` x2 | `secrets.tf` | db_password (24c) + admin_password (20c), chiffrés KMS |
| `aws_iam_role` + `aws_iam_instance_profile` | `iam.tf` | Role EC2 + policies scopées + SSM + CloudWatch |
 
### Points de sécurité
 
- Règles SG en ressources séparées (syntaxe AWS provider v5+)
- DB sans egress (isolation maximale)
- IAM policies scopées aux ARN précis (pas de wildcard sur `Resource`)
- KMS key policy : root account `kms:*` + rôle app `kms:Decrypt/DescribeKey/GenerateDataKey`
- `tfsec` : 0 erreur HIGH/CRITICAL
 
---
 
## Module `data`
 
### Requirements
 
| Nom | Version |
|-----|---------|
| `terraform` | >= 1.10 |
| `aws` | ~> 5.70 |
| `random` | ~> 3.6 |
 
### Resources
 
| Nom | Type |
|-----|------|
| `aws_db_instance.nextcloud` | resource |
| `aws_db_parameter_group.nextcloud` | resource |
| `aws_db_subnet_group.nextcloud` | resource |
| `aws_s3_bucket.logs` | resource |
| `aws_s3_bucket.primary` | resource |
| `aws_s3_bucket_lifecycle_configuration.logs` | resource |
| `aws_s3_bucket_policy.logs` | resource |
| `aws_s3_bucket_policy.primary` | resource |
| `aws_s3_bucket_public_access_block.logs` | resource |
| `aws_s3_bucket_public_access_block.primary` | resource |
| `aws_s3_bucket_server_side_encryption_configuration.logs` | resource |
| `aws_s3_bucket_server_side_encryption_configuration.primary` | resource |
| `aws_s3_bucket_versioning.primary` | resource |
| `random_pet.bucket_suffix` | resource |
 
### Inputs
 
| Nom | Description | Type | Défaut | Requis |
|-----|-------------|------|--------|:------:|
| `db_allocated_storage` | — | `number` | `20` | non |
| `db_engine_version` | — | `string` | `"16.4"` | non |
| `db_instance_class` | — | `string` | `"db.t3.micro"` | non |
| `db_max_allocated_storage` | Autoscaling storage (gp3) pour absorber les uploads Nextcloud | `number` | `100` | non |
| `db_password_secret_arn` | ARN du secret Secrets Manager contenant le mot de passe DB | `string` | — | oui |
| `db_security_group_id` | SG attaché au RDS (fourni par le module security) | `string` | — | oui |
| `environment` | — | `string` | `"dev"` | non |
| `kms_key_arn` | ARN de la CMK KMS (fournie par le module security) | `string` | — | oui |
| `private_db_subnet_ids` | Map AZ → subnet privé DB (2 subnets sur 2 AZ pour Multi-AZ) | `map(string)` | — | oui |
| `project_name` | — | `string` | `"isaie"` | non |
| `vpc_id` | ID du VPC (output du module networking) | `string` | — | oui |
 
### Outputs
 
| Nom | Description |
|-----|-------------|
| `db_endpoint` | Hostname RDS (sans le port) |
| `db_name` | Nom de la base logique |
| `db_port` | Port RDS PostgreSQL (5432) |
| `db_username` | Utilisateur master PostgreSQL |
| `s3_logs_bucket_arn` | ARN du bucket logs ALB |
| `s3_logs_bucket_name` | Nom du bucket access logs ALB |
| `s3_primary_bucket_arn` | ARN du bucket primary (consommé par le module security pour la policy IAM) |
| `s3_primary_bucket_name` | Nom du bucket primary storage Nextcloud |
 
---
 
## Module `compute`
 
### Requirements
 
| Nom | Version |
|-----|---------|
| `terraform` | >= 1.10 |
| `aws` | ~> 5.70 |
| `tls` | ~> 4.0 |
 
### Resources
 
| Nom | Type |
|-----|------|
| `aws_acm_certificate.self_signed` | resource |
| `aws_autoscaling_attachment.app_tg` | resource |
| `aws_autoscaling_group.app` | resource |
| `aws_launch_template.app` | resource |
| `aws_lb.main` | resource |
| `aws_lb_listener.http_redirect` | resource |
| `aws_lb_listener.https` | resource |
| `aws_lb_target_group.app` | resource |
| `tls_private_key.self_signed` | resource |
| `tls_self_signed_cert.alb` | resource |
| `aws_ami.al2023` | data source |
 
### Inputs
 
| Nom | Description | Type | Défaut | Requis |
|-----|-------------|------|--------|:------:|
| `admin_password_secret_arn` | ARN du secret du mot de passe admin Nextcloud | `string` | — | oui |
| `alb_security_group_id` | SG de l'ALB (fourni par le module security) | `string` | — | oui |
| `app_instance_profile_name` | Instance profile IAM pour l'ASG (fourni par security) | `string` | — | oui |
| `app_security_group_id` | SG des EC2 applicatives (fourni par le module security) | `string` | — | oui |
| `db_endpoint` | Hostname RDS (output du module data) | `string` | — | oui |
| `db_name` | — | `string` | — | oui |
| `db_password_secret_arn` | ARN du secret Secrets Manager contenant le mot de passe DB | `string` | — | oui |
| `db_username` | — | `string` | — | oui |
| `environment` | — | `string` | `"dev"` | non |
| `instance_type` | t3.small mini pour faire tourner Docker + Nextcloud | `string` | `"t3.small"` | non |
| `private_app_subnet_ids` | Map AZ → subnet privé (pour l'ASG) | `map(string)` | — | oui |
| `project_name` | — | `string` | `"kolab"` | non |
| `public_subnet_ids` | Map AZ → subnet public (pour l'ALB) | `map(string)` | — | oui |
| `s3_logs_bucket_name` | Nom du bucket S3 pour les access logs ALB | `string` | — | oui |
| `s3_primary_bucket_name` | Nom du bucket S3 primary storage Nextcloud | `string` | — | oui |
| `vpc_id` | ID du VPC (output du module networking) | `string` | — | oui |
 
### Outputs
 
| Nom | Description |
|-----|-------------|
| `alb_dns_name` | DNS public de l'ALB (cible du navigateur) |
| `alb_zone_id` | Zone Route53 alias pour l'ALB (utile si vous branchez un domaine) |
| `asg_name` | Nom de l'ASG (pour cycler les instances manuellement si besoin) |
| `launch_template_id` | ID du Launch Template (utile pour debug ASG) |
| `nextcloud_url` | URL finale Nextcloud à ouvrir dans le navigateur |
| `target_group_arn` | ARN du target group (utile pour attacher d'autres services) |
 
---
 
## Root module (environnement `dev`)
 
### Requirements
 
| Nom | Version |
|-----|---------|
| `terraform` | >= 1.10.0 |
| `aws` | ~> 5.0 |
| `random` | ~> 3.6 |
| `tls` | ~> 4.0 |
 
### Modules appelés
 
| Nom | Source |
|-----|--------|
| `networking` | `../../modules/networking` |
| `security` | `../../modules/security` |
| `data` | `../../modules/data` |
| `compute` | `../../modules/compute` |
 
### Inputs
 
| Nom | Description | Type | Défaut | Requis |
|-----|-------------|------|--------|:------:|
| `allowed_admin_cidr` | CIDR IP source autorisé pour l'accès HTTPS à l'ALB | `string` | — | oui |
| `aws_region` | Région AWS cible (eu-west-1 imposée par le CdC RGPD) | `string` | `"eu-west-1"` | non |
| `environment` | Nom de l'environnement (dev, staging, prod) | `string` | `"dev"` | non |
| `project_name` | Nom de projet utilisé pour nommer et tagger les ressources | `string` | `"kolab-group-1-lille"` | non |
 
### Outputs
 
| Nom | Description |
|-----|-------------|
| `admin_password_secret_arn` | ARN Secrets Manager du password admin Nextcloud |
| `alb_dns_name` | DNS public de l'ALB, à utiliser pour accéder à Nextcloud |
| `asg_name` | Nom de l'ASG applicatif |
| `db_endpoint` | Hostname RDS (non public) |
| `db_password_secret_arn` | ARN Secrets Manager du password DB |
| `nextcloud_url` | URL complète HTTPS de Nextcloud (self-signed : avertissement navigateur) |
| `s3_logs_bucket_name` | Bucket S3 access logs ALB |
| `s3_primary_bucket_name` | Bucket S3 primary storage Nextcloud |
| `vpc_id` | ID du VPC (debug) |