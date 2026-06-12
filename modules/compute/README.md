<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.70 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.self_signed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_autoscaling_attachment.app_tg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_attachment) | resource |
| [aws_autoscaling_group.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_launch_template.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_lb.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.http_redirect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [tls_private_key.self_signed](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.alb](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |
| [aws_ami.al2023](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password_secret_arn"></a> [admin\_password\_secret\_arn](#input\_admin\_password\_secret\_arn) | ARN du secret du mot de passe admin Nextcloud | `string` | n/a | yes |
| <a name="input_alb_security_group_id"></a> [alb\_security\_group\_id](#input\_alb\_security\_group\_id) | SG de l'ALB (fourni par le module security) | `string` | n/a | yes |
| <a name="input_app_instance_profile_name"></a> [app\_instance\_profile\_name](#input\_app\_instance\_profile\_name) | Instance profile IAM pour l'ASG (fourni par security) | `string` | n/a | yes |
| <a name="input_app_security_group_id"></a> [app\_security\_group\_id](#input\_app\_security\_group\_id) | SG des EC2 applicatives (fourni par le module security) | `string` | n/a | yes |
| <a name="input_db_endpoint"></a> [db\_endpoint](#input\_db\_endpoint) | Hostname RDS (output du module data) | `string` | n/a | yes |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | n/a | `string` | n/a | yes |
| <a name="input_db_password_secret_arn"></a> [db\_password\_secret\_arn](#input\_db\_password\_secret\_arn) | ARN du secret Secrets Manager contenant le mot de passe DB | `string` | n/a | yes |
| <a name="input_db_username"></a> [db\_username](#input\_db\_username) | n/a | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | `"dev"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | t3.small mini pour faire tourner Docker + Nextcloud confortablement | `string` | `"t3.small"` | no |
| <a name="input_private_app_subnet_ids"></a> [private\_app\_subnet\_ids](#input\_private\_app\_subnet\_ids) | Map AZ -> subnet\_id prive (pour l'ASG) | `map(string)` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | n/a | `string` | `"kolab"` | no |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | Map AZ -> subnet\_id public (pour l'ALB) | `map(string)` | n/a | yes |
| <a name="input_s3_logs_bucket_name"></a> [s3\_logs\_bucket\_name](#input\_s3\_logs\_bucket\_name) | Nom du bucket S3 pour les access logs ALB | `string` | n/a | yes |
| <a name="input_s3_primary_bucket_name"></a> [s3\_primary\_bucket\_name](#input\_s3\_primary\_bucket\_name) | Nom du bucket S3 primary storage Nextcloud | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID du VPC (output du module networking) | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | DNS public de l'ALB (cible du navigateur) |
| <a name="output_alb_zone_id"></a> [alb\_zone\_id](#output\_alb\_zone\_id) | Zone Route53 alias pour l'ALB (utilise si vous branchez un domaine) |
| <a name="output_asg_name"></a> [asg\_name](#output\_asg\_name) | Nom de l'ASG (pour cycler les instances manuellement si besoin) |
| <a name="output_launch_template_id"></a> [launch\_template\_id](#output\_launch\_template\_id) | ID du Launch Template (utile pour debug ASG) |
| <a name="output_nextcloud_url"></a> [nextcloud\_url](#output\_nextcloud\_url) | URL finale Nextcloud a ouvrir dans le navigateur |
| <a name="output_target_group_arn"></a> [target\_group\_arn](#output\_target\_group\_arn) | ARN du target group (utile pour attacher d'autres services) |
<!-- END_TF_DOCS -->
