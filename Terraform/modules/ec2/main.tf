locals {
  name_prefix = "${var.project_name}-${var.environment}-${var.server_role}"

  base_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Role        = var.server_role
  }
}

# --------------------------------------
# Launch Template
# --------------------------------------
resource "aws_launch_template" "this" {
  name          = "${local.name_prefix}-lt"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  description   = "Launch template for ${var.server_role} server"

  monitoring {
    enabled = true
  }

  vpc_security_group_ids = var.security_group_ids

 

  tag_specifications {
    resource_type = "instance"
    tags          = merge(local.base_tags, { Name = "${local.name_prefix}-ec2" })
  }

  tag_specifications {
    resource_type = "volume"
    tags          = merge(local.base_tags, { Name = "${local.name_prefix}-volume" })
  }

  tags = merge(local.base_tags, { Name = "${local.name_prefix}-lt" })
}

# Auto Scaling Group
# --------------------------------------
resource "aws_autoscaling_group" "this" {
  name                = "${local.name_prefix}-asg"
  vpc_zone_identifier = var.subnet_ids
  desired_capacity    = var.desired_capacity
  min_size            = var.min_size
  max_size            = var.max_size
  health_check_type   = "ELB"

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${local.name_prefix}-ec2"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project_name
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "Role"
    value               = var.server_role
    propagate_at_launch = true
  }

  tag {
    key                 = "ManagedBy"
    value               = "terraform"
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [target_group_arns]
  }
}

# --------------------------------------
# ALB Target Group Attachment
# --------------------------------------
resource "aws_autoscaling_attachment" "this" {
  count                  = var.enable_alb_attachment ? 1 : 0
  autoscaling_group_name = aws_autoscaling_group.this.id
  lb_target_group_arn    = var.target_group_arn
}

# --------------------------------------
# ASG Notifications via SNS
# --------------------------------------
resource "aws_sns_topic" "asg_notifications" {
  name = "${local.name_prefix}-asg-notifications"
  tags = merge(local.base_tags, { Name = "${local.name_prefix}-sns" })
}

resource "aws_autoscaling_notification" "this" {
  group_names = [aws_autoscaling_group.this.name]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]

  topic_arn = aws_sns_topic.asg_notifications.arn
}

# --------------------------------------
# Auto Scaling Policy (CPU based)
# --------------------------------------
resource "aws_autoscaling_policy" "scale_out" {
  count                  = var.enable_autoscaling ? 1 : 0
  name                   = "${local.name_prefix}-scale-out"
  autoscaling_group_name = aws_autoscaling_group.this.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}

resource "aws_autoscaling_policy" "scale_in" {
  count                  = var.enable_autoscaling ? 1 : 0
  name                   = "${local.name_prefix}-scale-in"
  autoscaling_group_name = aws_autoscaling_group.this.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
}