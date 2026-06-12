terraform {
  backend "s3" {
    # Meme bucket que envs/dev mais cle differente
    bucket = "tf-state-kolab-formation-TEAM"
    key    = "global/iam-github-oidc/terraform.tfstate"
    region = "eu-west-1"

    encrypt    = true
    kms_key_id = "alias/tf-state-kolab-formation"

    use_lockfile = true
  }
}
