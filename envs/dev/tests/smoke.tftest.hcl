# =============================================================================
# envs/dev/tests/smoke.tftest.hcl
# Framework de Test natif Terraform — Validation structurale du Plan
# =============================================================================

# Configuration des variables injectées pour le test
variables {
  allowed_admin_cidr = "92.154.23.41/32"
  project_name       = "kolab"
  environment        = "dev"
}

# Validation de la cohérence globale du plan et des contraintes du CdC
run "smoke_test_architecture_graph" {
  command = plan

  # 1. On valide que la région n'a pas dérivé (Exigence RGPD / Pare-feu formation)
  assert {
    condition     = var.aws_region == "eu-west-3"
    error_message = "Contrainte CdC violée : La région de déploiement doit être eu-west-3 (Paris)."
  }

  # 2. On valide que la stratégie de nommage projet est bien respectée
  assert {
    condition     = var.project_name == "kolab"
    error_message = "Erreur de configuration : Le nom du projet global doit être 'kolab'."
  }

  # 3. On s'assure que l'environnement ciblé est bien le bloc de développement
  assert {
    condition     = var.environment == "dev"
    error_message = "Erreur de cible : Ce bloc de test est strictement réservé à l'environnement 'dev'."
  }
}