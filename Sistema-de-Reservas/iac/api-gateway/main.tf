terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  name_prefix = "${var.project_name}-${var.environment}"
  base_tags = merge({
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Module      = "api-gateway"
  }, var.tags)
}

# ─────────────────────────────────────────────────────────────────────────────
# HTTP API (API Gateway v2)
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_apigatewayv2_api" "main" {
  name          = "${local.name_prefix}-api-gw"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_headers = ["Content-Type", "Authorization"]
    max_age       = 300
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# VPC LINK — conecta API GW con el ALB en la VPC
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_apigatewayv2_integration" "alb" {
  api_id             = aws_apigatewayv2_api.main.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = "http://${var.alb_dns_name}/{proxy}"
  integration_method = "ANY"
}

# ─────────────────────────────────────────────────────────────────────────────
# RUTA — todo el tráfico va al ALB
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_apigatewayv2_route" "default" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "ANY /{proxy+}"
  target             = "integrations/${aws_apigatewayv2_integration.alb.id}"
  authorization_type = "NONE"
}

# ─────────────────────────────────────────────────────────────────────────────
# STAGE — deploy automático
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn
    format          = "$context.requestId - $context.httpMethod $context.path $context.status"
  }
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name              = "/aws/apigateway/${local.name_prefix}"
  retention_in_days = 365
  kms_key_id        = var.kms_key_arn
}