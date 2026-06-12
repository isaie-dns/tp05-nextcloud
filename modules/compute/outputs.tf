output "alb_dns_name" {
  value       = aws_lb.main.dns_name
  description = "DNS public de l'ALB (cible du navigateur)"
}

output "alb_zone_id" {
  value       = aws_lb.main.zone_id
  description = "Zone Route53 alias pour l'ALB (utilise si vous branchez un domaine)"
}

output "asg_name" {
  value       = aws_autoscaling_group.app.name
  description = "Nom de l'ASG (pour cycler les instances manuellement si besoin)"
}

output "nextcloud_url" {
  value       = try("https://${aws_lb.main.dns_name}", null)
  description = "URL d'accès à Nextcloud via l'ALB"
}

output "launch_template_id" {
  value       = aws_launch_template.app.id
  description = "ID du Launch Template (utile pour debug ASG)"
}

output "target_group_arn" {
  value       = aws_lb_target_group.app.arn
  description = "ARN du target group (utile pour attacher d'autres services)"
}
