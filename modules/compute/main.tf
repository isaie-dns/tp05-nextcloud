# modules/compute/main.tf


data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["etudiant07"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}
