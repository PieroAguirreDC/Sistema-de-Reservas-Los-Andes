# ─────────────────────────────────────────────────────────────────────────────
# ROOT MODULE — Orquesta todos los módulos IaC del Sistema de Reservas Los Andes
# Orden de dependencias: vpc → security → rds + elasticache + messaging
# ─────────────────────────────────────────────────────────────────────────────

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
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# MÓDULO 1: VPC — Red base (sin dependencias)
# ─────────────────────────────────────────────────────────────────────────────
module "vpc" {
  source = "./vpc"

  aws_region           = var.aws_region
  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  enable_vpc_endpoints = var.enable_vpc_endpoints
  tags                 = var.tags
}

# ─────────────────────────────────────────────────────────────────────────────
# MÓDULO 2: SECURITY — KMS, Secrets Manager, Security Groups
# Depende de: vpc
# ─────────────────────────────────────────────────────────────────────────────
module "security" {
  source = "./security"

  aws_region          = var.aws_region
  project_name        = var.project_name
  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  vpc_cidr            = module.vpc.vpc_cidr
  private_app_cidrs   = module.vpc.private_app_cidrs
  kms_deletion_window = var.kms_deletion_window
  tags                = var.tags
}

# ─────────────────────────────────────────────────────────────────────────────
# MÓDULO 3: RDS — Aurora PostgreSQL + Proxy + Backup
# Depende de: vpc, security
# ─────────────────────────────────────────────────────────────────────────────
module "rds" {
  source = "./rds"

  aws_region            = var.aws_region
  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  private_db_subnet_ids = module.vpc.private_db_subnet_ids
  availability_zones    = module.vpc.availability_zones
  kms_key_arn           = module.security.kms_key_arn
  sg_rds_id             = module.security.sg_rds_id
  secret_rds_arn        = module.security.secret_rds_arn

  # Aurora config
  aurora_instance_class = var.aurora_instance_class
  aurora_engine_version = var.aurora_engine_version
  aurora_database_name  = var.aurora_database_name
  aurora_port           = var.aurora_port

  # Backup
  backup_retention_days     = var.backup_retention_days
  backup_window             = var.backup_window
  maintenance_window        = var.maintenance_window
  aws_backup_retention_days = var.aws_backup_retention_days

  # Contraseña inyectada vía TF_VAR_db_master_password (nunca en tfvars)
  db_master_password = var.db_master_password

  tags = var.tags
}

# ─────────────────────────────────────────────────────────────────────────────
# MÓDULO 4: ELASTICACHE — Redis con failover Multi-AZ
# Depende de: vpc, security
# ─────────────────────────────────────────────────────────────────────────────
module "elasticache" {
  source = "./elasticache"

  aws_region            = var.aws_region
  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  private_db_subnet_ids = module.vpc.private_db_subnet_ids
  availability_zones    = module.vpc.availability_zones
  sg_elasticache_id     = module.security.sg_elasticache_id
  kms_key_arn           = module.security.kms_key_arn

  node_type            = var.redis_node_type
  redis_engine_version = var.redis_engine_version

  # Auth token inyectado vía TF_VAR_redis_auth_token (nunca en tfvars)
  redis_auth_token = var.redis_auth_token

  tags = var.tags
}

# ─────────────────────────────────────────────────────────────────────────────
# MÓDULO 5: MESSAGING — SNS + SQS + DLQs
# Depende de: security (KMS)
# ─────────────────────────────────────────────────────────────────────────────
module "messaging" {
  source = "./messaging"

  aws_region   = var.aws_region
  project_name = var.project_name
  environment  = var.environment
  kms_key_arn  = module.security.kms_key_arn
  tags         = var.tags
}
