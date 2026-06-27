terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.base_tags
  }
}

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  base_tags = merge({
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Module      = "alb"
  }, var.tags)
}

# ─────────────────────────────────────────────────────────────────────────────
# APPLICATION LOAD BALANCER
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_lb" "main" {
  name               = "${local.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg_alb_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = var.environment == "prod" ? true : false

  tags = {
    Name = "${local.name_prefix}-alb"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# TARGET GROUP — Apunta a los contenedores ECS Fargate
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_lb_target_group" "api" {
  name        = "${local.name_prefix}-api-tg"
  port        = 3000
  protocol    = "https"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/api/v1/health"
    protocol            = "https"
    matcher             = "200"
  }

  tags = {
    Name = "${local.name_prefix}-api-tg"
  }
}

resource "aws_lb_target_group" "web" {
  name        = "${local.name_prefix}-web-tg"
  port        = 3001
  protocol    = "https"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/"
    protocol            = "https"
    matcher             = "200"
  }

  tags = {
    Name = "${local.name_prefix}-web-tg"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# LISTENER HTTP — Redirige todo a HTTPS
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "https"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# LISTENER HTTPS — Enruta por path
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_lb_listener" "https" {
  count             = var.certificate_arn != "" ? 1 : 0
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# LISTENER RULE — /api/v1/* va al target group de la API
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_lb_listener_rule" "api" {
  count        = var.certificate_arn != "" ? 1 : 0
  listener_arn = aws_lb_listener.https[0].arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }

  condition {
    path_pattern {
      values = ["/api/v1/*"]
    }
  }
}