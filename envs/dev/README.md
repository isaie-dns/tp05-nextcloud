<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.80 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.80 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_compute"></a> [compute](#module\_compute) | ../../modules/compute | n/a |
| <a name="module_data"></a> [data](#module\_data) | ../../modules/data | n/a |
| <a name="module_networking"></a> [networking](#module\_networking) | ../../modules/networking | n/a |
| <a name="module_security"></a> [security](#module\_security) | ../../modules/security | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role_policy.app_s3_scoped](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_admin_cidr"></a> [allowed\_admin\_cidr](#input\_allowed\_admin\_cidr) | CIDR IP autorise a atteindre l ALB en HTTPS (IP formateur). | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Region AWS (impose : eu-west-3 pour RGPD). | `string` | `"eu-west-3"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Nom de l environnement. | `string` | `"dev"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Nom de projet pour le tagging. | `string` | `"kolab"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | DNS public de l'ALB pour atteindre Nextcloud. |
| <a name="output_nextcloud_url"></a> [nextcloud\_url](#output\_nextcloud\_url) | URL complète sécurisée de l'instance Nextcloud. |
| <a name="output_s3_primary_bucket_name"></a> [s3\_primary\_bucket\_name](#output\_s3\_primary\_bucket\_name) | Nom du bucket S3 de stockage primaire Nextcloud créé. |
<!-- END_TF_DOCS -->