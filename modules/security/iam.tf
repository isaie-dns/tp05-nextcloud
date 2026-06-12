data "aws_iam_policy_document" "app_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "app" {
  name                 = "${var.project_name}-${var.environment}-app-role"
  assume_role_policy   = data.aws_iam_policy_document.app_assume_role.json
  permissions_boundary = "arn:aws:iam::039497794217:policy/formation-permissions-boundary-paris"
  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_iam_instance_profile" "app" {
  name = "${var.project_name}-${var.environment}-app-profile"
  role = aws_iam_role.app.name
}
