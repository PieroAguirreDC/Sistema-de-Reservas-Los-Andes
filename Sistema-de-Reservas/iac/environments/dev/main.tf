# ═════════════════════════════════════════════════════════════════════════════
# ENVIRONMENTS / DEV — Punto de entrada real de Terraform
# Aquí se "llama" a todos los módulos con valores concretos para el entorno dev.
# Los módulos hijos (../../vpc, ../../security, etc.) NO tienen su propio
# provider — lo heredan de aquí.
# ═════════════════════════════════════════════════════════════════════════════

terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # backend "s3" {
  #   bucket         = "reservas-terraform-state"
  #   key            = "dev/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "reservas-terraform-locks"
  #   encrypt        = true
  # }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile != "" ? var.aws_profile : null

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# SECRETOS GENERADOS — se crean una sola vez aquí y se reparten a los módulos
# que los necesitan, para que NUNCA queden desincronizados entre sí.
# ─────────────────────────────────────────────────────────────────────────────
resource "random_password" "db_master_password" {
  length  = 24
  special = false # Aurora rechaza algunos caracteres especiales en el password
}

resource "random_password" "redis_auth_token" {
  length  = 32
  special = false # ElastiCache auth token no admite todos los símbolos
}

# ═════════════════════════════════════════════════════════════════════════════
# FASE 1 — INFRAESTRUCTURA BASE
# ═════════════════════════════════════════════════════════════════════════════

# ─── VPC ────────────────────────────────────────────────────────────────────
module "vpc" {
  source = "../../vpc"

  aws_region           = var.aws_region
  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  enable_vpc_endpoints = true
  tags                 = var.tags
}

# ─── SECURITY (SGs, KMS, Secrets Manager) ────────────────────────────────────
module "security" {
  source = "../../security"

  aws_region          = var.aws_region
  project_name        = var.project_name
  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  vpc_cidr            = module.vpc.vpc_cidr
  private_app_cidrs   = module.vpc.private_app_cidrs
  kms_deletion_window = 7
  db_master_password  = random_password.db_master_password.result
  tags                = var.tags
}

# ─── RDS (Aurora PostgreSQL + Proxy + Backup) ────────────────────────────────
module "rds" {
  source = "../../rds"

  aws_region            = var.aws_region
  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  private_db_subnet_ids = module.vpc.private_db_subnet_ids
  availability_zones    = module.vpc.availability_zones
  kms_key_arn           = module.security.kms_key_arn
  sg_rds_id             = module.security.sg_rds_id
  secret_rds_arn        = module.security.secret_rds_arn
  db_master_password    = random_password.db_master_password.result

  aurora_instance_class     = "db.t3.medium" # dev: barato. prod usará db.r6g.large
  aurora_engine_version     = "15.8"
  aurora_database_name      = "reservas_db"
  backup_retention_days     = 1
  aws_backup_retention_days = 7

  tags = var.tags
}

# ─── ELASTICACHE (Redis) ──────────────────────────────────────────────────────
module "elasticache" {
  source = "../../elasticache"

  aws_region            = var.aws_region
  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  private_db_subnet_ids = module.vpc.private_db_subnet_ids
  availability_zones    = module.vpc.availability_zones
  sg_elasticache_id     = module.security.sg_elasticache_id
  kms_key_arn           = module.security.kms_key_arn
  node_type             = "cache.t3.micro" # dev: barato. prod usará cache.r6g.large
  redis_engine_version  = "7.0"
  redis_auth_token      = random_password.redis_auth_token.result

  tags = var.tags
}

# ─── MESSAGING (SNS/SQS) ──────────────────────────────────────────────────────
module "messaging" {
  source = "../../messaging"

  aws_region   = var.aws_region
  project_name = var.project_name
  environment  = var.environment
  kms_key_arn  = module.security.kms_key_arn
  tags         = var.tags
}

# ─── S3 BUCKETS ───────────────────────────────────────────────────────────────
module "s3" {
  source = "../../s3"

  project_name           = var.project_name
  environment            = var.environment
  kms_key_arn            = module.security.kms_key_arn
  allowed_upload_origins = ["http://localhost:3001"]
  tags                   = var.tags
}

# ═════════════════════════════════════════════════════════════════════════════
# FASE 2 — ECR
# ═════════════════════════════════════════════════════════════════════════════
module "ecr" {
  source = "../../ecr"

  aws_region   = var.aws_region
  project_name = var.project_name
  environment  = var.environment
  kms_key_arn  = module.security.kms_key_arn
  tags         = var.tags
}

# ═════════════════════════════════════════════════════════════════════════════
# FASE 3 — CÓMPUTO Y EXPOSICIÓN
# ═════════════════════════════════════════════════════════════════════════════

# ─── ALB ──────────────────────────────────────────────────────────────────────
module "alb" {
  source = "../../alb"

  aws_region        = var.aws_region
  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  sg_alb_id         = module.security.sg_alb_id
  certificate_arn   = var.certificate_arn
  tags              = var.tags
}

# ─── ECS FARGATE ───────────────────────────────────────────────────────────────
module "ecs_fargate" {
  source = "../../ecs-fargate"

  aws_region         = var.aws_region
  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_app_subnet_ids
  sg_ecs_id          = module.security.sg_ecs_id
  kms_key_arn        = module.security.kms_key_arn

  # ARNs de los Target Groups
  usuarios_target_group_arn       = module.alb.usuarios_target_group_arn
  habitaciones_target_group_arn   = module.alb.habitaciones_target_group_arn
  reservas_target_group_arn       = module.alb.reservas_target_group_arn
  pagos_target_group_arn          = module.alb.pagos_target_group_arn
  notificaciones_target_group_arn = module.alb.notificaciones_target_group_arn
  web_target_group_arn            = module.alb.web_target_group_arn

  # URIs de imágenes para los microservicios y frontend
  usuarios_image_uri       = "${module.ecr.usuarios_repository_url}:latest"
  habitaciones_image_uri   = "${module.ecr.habitaciones_repository_url}:latest"
  reservas_image_uri       = "${module.ecr.reservas_repository_url}:latest"
  pagos_image_uri          = "${module.ecr.pagos_repository_url}:latest"
  notificaciones_image_uri = "${module.ecr.notificaciones_repository_url}:latest"
  web_image_uri            = "${module.ecr.web_repository_url}:latest"

  api_cpu       = 256
  api_memory    = 512
  web_cpu       = 256
  web_memory    = 512
  desired_count = 1

  # Base de datos
  rds_proxy_endpoint   = module.rds.rds_proxy_endpoint
  aurora_database_name = module.rds.aurora_database_name
  aurora_port          = module.rds.aurora_port
  secret_rds_arn       = module.security.secret_rds_arn

  # Cache
  redis_primary_endpoint = module.elasticache.redis_primary_endpoint
  redis_port             = module.elasticache.redis_port

  # S3
  s3_bucket_public      = module.s3.uploads_public_bucket_name
  s3_bucket_private     = module.s3.uploads_private_bucket_name
  s3_uploads_policy_arn = module.s3.backend_uploads_policy_arn

  # Mensajería
  sns_topic_reservas_arn          = module.messaging.sns_topic_reservas_arn
  sns_topic_pagos_arn             = module.messaging.sns_topic_pagos_arn
  sqs_reservas_notificaciones_arn = module.messaging.sqs_reservas_notificaciones_arn
  sqs_pagos_notificaciones_arn    = module.messaging.sqs_pagos_notificaciones_arn
  sqs_reservas_pagos_arn          = module.messaging.sqs_reservas_pagos_arn
  sqs_reservas_notificaciones_url = module.messaging.sqs_reservas_notificaciones_url
  sqs_pagos_notificaciones_url    = module.messaging.sqs_pagos_notificaciones_url
  sqs_reservas_pagos_url          = module.messaging.sqs_reservas_pagos_url

  tags = var.tags
}

# ─── API GATEWAY ────────────────────────────────────────────────────────────────
module "api_gateway" {
  source = "../../api-gateway"

  aws_region   = var.aws_region
  project_name = var.project_name
  environment  = var.environment
  alb_dns_name = module.alb.alb_dns_name
  kms_key_arn  = module.security.kms_key_arn
  tags         = var.tags
}

# ─── CLOUDFRONT (CDN) ───────────────────────────────────────────────────────────
module "cloudfront" {
  source = "../../cloudfront"

  project_name                = var.project_name
  environment                 = var.environment
  frontend_bucket_id          = module.s3.frontend_static_bucket_name
  frontend_bucket_arn         = module.s3.frontend_static_bucket_arn
  frontend_bucket_domain_name = module.s3.frontend_static_bucket_regional_domain_name
  api_gateway_domain_name     = replace(module.api_gateway.api_endpoint, "/^https?:\\/\\/([^\\/]+).*/", "$1")
  tags                        = var.tags
}

# ─── COGNITO ──────────────────────────────────────────────────────────────────
module "cognito" {
  source = "../../cognito"

  project_name = var.project_name
  environment  = var.environment
  tags         = var.tags
}

# ─── ROUTE 53 ─────────────────────────────────────────────────────────────────
module "route53" {
  source = "../../route53"

  project_name           = var.project_name
  environment            = var.environment
  domain_name            = "reservas-${var.environment}.local"
  cloudfront_domain_name = module.cloudfront.cloudfront_domain_name
  tags                   = var.tags
}

# ─── MONITORING (CloudWatch) ────────────────────────────────────────────────────
module "monitoring" {
  source = "../../monitoring"

  aws_region                  = var.aws_region
  project_name                = var.project_name
  environment                 = var.environment
  cluster_name                = module.ecs_fargate.cluster_name
  usuarios_service_name       = module.ecs_fargate.usuarios_service_name
  habitaciones_service_name   = module.ecs_fargate.habitaciones_service_name
  reservas_service_name       = module.ecs_fargate.reservas_service_name
  pagos_service_name          = module.ecs_fargate.pagos_service_name
  notificaciones_service_name = module.ecs_fargate.notificaciones_service_name
  web_service_name            = module.ecs_fargate.web_service_name
  alb_arn                     = module.alb.alb_arn
  usuarios_target_group_arn   = module.alb.usuarios_target_group_arn
  kms_key_arn                 = module.security.kms_key_arn
  alarm_email                 = var.alarm_email
  tags                        = var.tags
}
