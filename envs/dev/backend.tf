# =============================================================================
# envs/dev/backend.tf
# =============================================================================

terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    bucket       = "tf-state-group-1-lille-kolab" # <- Le nom réel de ton bucket AWS !
    key          = "envs/dev/terraform.tfstate"
    region       = "eu-west-3"
    encrypt      = true
    kms_key_id   = "alias/tf-state-group-1-lille" # <- Aligné sur le nom du groupe
    use_lockfile = true
  }
}
