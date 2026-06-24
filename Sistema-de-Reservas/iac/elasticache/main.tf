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
    Module      = "elasticache"
  }, var.tags)
}

# ─────────────────────────────────────────────────────────────────────────────
# SUBNET GROUP — Define en qué subredes vive Redis
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_elasticache_subnet_group" "main" {
  name       = "${local.name_prefix}-redis-subnet-group"
  subnet_ids = var.private_db_subnet_ids

  tags = {
    Name = "${local.name_prefix}-redis-subnet-group"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# REPLICATION GROUP — Primary + 1 Replica (failover automático)
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_elasticache_replication_group" "main" {
  replication_group_id       = "${local.name_prefix}-redis"
  description                = "Redis para Sistema de Reservas ${local.name_prefix}"
  node_type                  = var.node_type
  num_cache_clusters         = 2
  automatic_failover_enabled = true
  engine                     = "redis"
  engine_version             = var.redis_engine_version
  port                       = 6379
  subnet_group_name          = aws_elasticache_subnet_group.main.name
  security_group_ids         = [var.sg_elasticache_id]
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  kms_key_id                 = var.kms_key_arn

  preferred_cache_cluster_azs = [
    var.availability_zones[0],
    var.availability_zones[1]
  ]

  tags = {
    Name = "${local.name_prefix}-redis"
  }
}