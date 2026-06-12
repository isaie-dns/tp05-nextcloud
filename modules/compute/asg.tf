
# AMI Amazon Linux 2023 (x86_64) la plus recente
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

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

# Launch Template : recette de construction d'une EC2
resource "aws_launch_template" "app" {
  name_prefix   = "${local.name_prefix}-lt-"
  image_id      = data.aws_ami.al2023.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.app_instance_profile_name
  }

  vpc_security_group_ids = [var.app_security_group_id]

  metadata_options {
    http_tokens                 = "required"
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  user_data = base64encode(templatefile("${path.module}/templates/nextcloud-user-data.sh.tftpl", {
    db_endpoint               = var.db_endpoint
    db_name                   = var.db_name
    db_username               = var.db_username
    db_password_secret_arn    = var.db_password_secret_arn
    admin_password_secret_arn = var.admin_password_secret_arn
    s3_primary_bucket_name    = var.s3_primary_bucket_name
    alb_dns_name              = aws_lb.main.dns_name
    aws_region                = "eu-west-3"
  }))

  tag_specifications {
    resource_type = "instance"
    tags = merge(local.common_tags, {
      Name = "${local.name_prefix}-app"
      Role = "nextcloud-app"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(local.common_tags, {
      Name = "${local.name_prefix}-app-volume"
    })
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-launch-template"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "app" {
  name = "${local.name_prefix}-asg"

  vpc_zone_identifier = local.private_app_subnet_ids_list

  min_size         = 1
  max_size         = 2
  desired_capacity = 1

  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
      instance_warmup        = 300
    }
  }

  tag {
    key                 = "Name"
    value               = "${local.name_prefix}-app"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project_name
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Rattachement ASG <-> Target Group
resource "aws_autoscaling_attachment" "app_tg" {
  autoscaling_group_name = aws_autoscaling_group.app.name
  lb_target_group_arn    = aws_lb_target_group.app.arn
}


