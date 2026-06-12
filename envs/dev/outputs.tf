# =============================================================================
# envs/dev/outputs.tf
# Points d'accès et outputs exposés pour la validation du TP
# =============================================================================

output "alb_dns_name" {
  description = "DNS public de l'ALB pour atteindre Nextcloud."
  value       = module.compute.alb_dns_name
}

output "nextcloud_url" {
  description = "URL complète sécurisée de l'instance Nextcloud."
  value       = module.compute.nextcloud_url
}

output "s3_primary_bucket_name" {
  description = "Nom du bucket S3 de stockage primaire Nextcloud créé."
  value       = module.data.s3_primary_bucket_name
}
