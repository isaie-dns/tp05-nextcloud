# -----------------------------------------------------------------------------
# modules/compute/main.tf
#
# Point d'entree du module compute. Les ressources sont organisees par fichier
# pour faciliter la review :
#   - tls.tf   : certificat self-signed (tls_private_key, tls_self_signed_cert, ACM)
#   - alb.tf   : Application Load Balancer, target group, listeners
#   - asg.tf   : AMI data source, Launch Template, Auto Scaling Group
#   - locals.tf / variables.tf / outputs.tf : interface du module
# -----------------------------------------------------------------------------
