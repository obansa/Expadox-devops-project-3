locals {
  name_prefix = "${var.project_name}-${var.environment}"

  base_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# ============================================
# ALB SECURITY GROUP
# ============================================

resource "aws_security_group" "alb_sg" {
  name        = "${local.name_prefix}-alb-sg"
  description = "ALB security group"
  vpc_id      = var.vpc_id
  tags        = merge(local.base_tags, { Name = "${local.name_prefix}-alb-sg" })
}

resource "aws_security_group_rule" "alb_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
  description       = "Allow HTTP"
}

resource "aws_security_group_rule" "alb_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
  description       = "Allow HTTPS"
}

resource "aws_security_group_rule" "alb_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
  description       = "Allow all outbound"
}

# ============================================
# APPLICATION LOAD BALANCER
# ============================================

resource "aws_lb" "alb" {
  name                       = "${local.name_prefix}-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_sg.id]
  subnets                    = [var.public_subnet_1_id, var.public_subnet_2_id]
  enable_deletion_protection = false
  tags                       = merge(local.base_tags, { Name = "${local.name_prefix}-alb" })
}

# ============================================
# TARGET GROUP
# ============================================

resource "aws_lb_target_group" "alb_target_group" {
  name        = "${local.name_prefix}-tg"
  target_type = var.target_type
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  tags        = merge(local.base_tags, { Name = "${local.name_prefix}-tg" })

  health_check {
    healthy_threshold   = 5
    interval            = 30
    matcher             = "200,301,302"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
}

# ============================================
# HTTP LISTENER
# ============================================

resource "aws_lb_listener" "alb_http_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  tags              = merge(local.base_tags, { Name = "${local.name_prefix}-http-listener" })

  default_action {
    type = var.enable_https ? "redirect" : "forward"

    dynamic "redirect" {
      for_each = var.enable_https ? [1] : []
      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    dynamic "forward" {
      for_each = var.enable_https ? [] : [1]
      content {
        target_group {
          arn = aws_lb_target_group.alb_target_group.arn
        }
      }
    }
  }
}

# ============================================
# HTTPS LISTENER (prod only)
# ============================================

resource "aws_lb_listener" "alb_https_listener" {
  count             = var.enable_https ? 1 : 0
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn
  tags              = merge(local.base_tags, { Name = "${local.name_prefix}-https-listener" })

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}