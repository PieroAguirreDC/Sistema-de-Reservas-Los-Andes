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
    Module      = "security"
  }, var.tags)
}

data "aws_caller_identity" "current" {}

# ─────────────────────────────────────────────────────────────────────────────
# KMS — Clave maestra para cifrar RDS, Secrets Manager y ElastiCache
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_kms_key" "main" {
  description             = "Clave KMS principal para ${local.name_prefix}"
  deletion_window_in_days = var.kms_deletion_window
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "PermitirAdminDesdeCuenta"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "PermitirUsoDesdeServicios"
        Effect = "Allow"
        Principal = {
          Service = [
            "rds.amazonaws.com",
            "secretsmanager.amazonaws.com",
            "elasticache.amazonaws.com",
            "logs.amazonaws.com"
          ]
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${local.name_prefix}-kms"
  }
}

resource "aws_kms_alias" "main" {
  name          = "alias/${local.name_prefix}-key"
  target_key_id = aws_kms_key.main.key_id
}

# ─────────────────────────────────────────────────────────────────────────────
# SECRETS MANAGER — Secreto base para credenciales de RDS
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_secretsmanager_secret" "rds_credentials" {
  name                    = "${local.name_prefix}/rds/credentials"
  description             = "Credenciales de Aurora PostgreSQL para ${local.name_prefix}"
  kms_key_id              = aws_kms_key.main.arn
  recovery_window_in_days = 7

  tags = {
    Name = "${local.name_prefix}-secret-rds"
  }
}

resource "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id = aws_secretsmanager_secret.rds_credentials.id

  secret_string = jsonencode({
    username = "admin_${var.project_name}"
    password = "CAMBIAR_ANTES_DE_APPLY"
    engine   = "aurora-postgresql"
    port     = 5432
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# ALB (recibe tráfico HTTPS desde internet)
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-sg-alb"
  description = "SG del Application Load Balancer — permite HTTPS desde internet"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS desde internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP desde internet (redirect a HTTPS)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Hacia microservicios en subredes de app"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name = "${local.name_prefix}-sg-alb"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# SECURITY GROUP — ECS Fargate (microservicios)
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_security_group" "ecs" {
  name        = "${local.name_prefix}-sg-ecs"
  description = "SG de los microservicios ECS — solo recibe tráfico desde el ALB"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Tráfico desde el ALB"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Salida hacia VPC (RDS, ElastiCache, VPC Endpoints)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name = "${local.name_prefix}-sg-ecs"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# RDS Aurora
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_security_group" "rds" {
  name        = "${local.name_prefix}-sg-rds"
  description = "SG de Aurora PostgreSQL — solo acepta conexiones desde ECS"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL desde microservicios ECS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    description = "Respuesta hacia ECS"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name = "${local.name_prefix}-sg-rds"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# ElastiCache Redis
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_security_group" "elasticache" {
  name        = "${local.name_prefix}-sg-elasticache"
  description = "SG de ElastiCache Redis — solo acepta conexiones desde ECS"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Redis desde microservicios ECS"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    description = "Respuesta hacia ECS"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name = "${local.name_prefix}-sg-elasticache"
  }
}