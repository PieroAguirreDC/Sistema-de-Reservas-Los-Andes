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
    Module      = "rds"
  }, var.tags)
}

# ─────────────────────────────────────────────────────────────────────────────
# SUBNET GROUP — Define en qué subredes vive Aurora
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_db_subnet_group" "main" {
  name        = "${local.name_prefix}-aurora-subnet-group"
  description = "Subnet group para Aurora PostgreSQL ${local.name_prefix}"
  subnet_ids  = var.private_db_subnet_ids

  tags = {
    Name = "${local.name_prefix}-aurora-subnet-group"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# PARAMETER GROUP — Configuración del motor PostgreSQL estándar
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_db_parameter_group" "main" {
  name        = "${local.name_prefix}-pg-params"
  family      = "postgres15"
  description = "Parameter group para RDS PostgreSQL ${local.name_prefix}"

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }

  parameter {
    name  = "log_statement"
    value = "all"
  }

  tags = {
    Name = "${local.name_prefix}-pg-params"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# RDS PostgreSQL — instancia única (Free Tier: db.t3.micro)
# Aurora no está disponible en cuentas free tier (FreeTierRestrictionError)
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_db_instance" "main" {
  identifier = "${local.name_prefix}-db"

  engine         = "postgres"
  engine_version = "15"
  instance_class = "db.t3.micro"

  db_name  = var.aurora_database_name
  username = "admin_${var.project_name}"
  password = var.db_master_password
  port     = var.aurora_port

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.sg_rds_id]
  parameter_group_name   = aws_db_parameter_group.main.name

  # Almacenamiento — Free Tier: hasta 20 GB gp2
  allocated_storage = 20
  storage_type      = "gp2"
  storage_encrypted = true
  kms_key_id        = var.kms_key_arn

  # Autenticación IAM
  iam_database_authentication_enabled = true

  # Logs a CloudWatch
  enabled_cloudwatch_logs_exports = ["postgresql"]

  # Backup
  backup_retention_period = 7
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window
  copy_tags_to_snapshot   = true

  # Free Tier: sin Multi-AZ ni standby
  multi_az = false

  # Monitoring mejorado
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_enhanced_monitoring.arn

  # Performance Insights
  performance_insights_enabled          = true
  performance_insights_kms_key_id       = var.kms_key_arn
  performance_insights_retention_period = 7

  deletion_protection = false
  skip_final_snapshot = true

  tags = {
    Name = "${local.name_prefix}-db"
  }
}



# ─────────────────────────────────────────────────────────────────────────────
# IAM ROLE para Enhanced Monitoring (RDS publica métricas del OS a CloudWatch)
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_iam_role" "rds_enhanced_monitoring" {
  name = "${local.name_prefix}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "monitoring.rds.amazonaws.com" }
    }]
  })

  tags = {
    Name = "${local.name_prefix}-rds-monitoring-role"
  }
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  role       = aws_iam_role.rds_enhanced_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# ─────────────────────────────────────────────────────────────────────────────
# RDS PROXY — Deshabilitado: no disponible en cuentas free tier
# Para habilitar: descomentar y hacer terraform apply
# ─────────────────────────────────────────────────────────────────────────────
# resource "aws_db_proxy" "main" {
#   name                   = "${local.name_prefix}-rds-proxy"
#   debug_logging          = false
#   engine_family          = "POSTGRESQL"
#   idle_client_timeout    = 1800
#   require_tls            = true
#   role_arn               = aws_iam_role.rds_proxy.arn
#   vpc_security_group_ids = [var.sg_rds_id]
#   vpc_subnet_ids         = var.private_db_subnet_ids
#
#   auth {
#     auth_scheme = "SECRETS"
#     iam_auth    = "DISABLED"
#     secret_arn  = var.secret_rds_arn
#   }
#
#   tags = {
#     Name = "${local.name_prefix}-rds-proxy"
#   }
# }
#
# resource "aws_db_proxy_default_target_group" "main" {
#   db_proxy_name = aws_db_proxy.main.name
#
#   connection_pool_config {
#     max_connections_percent      = 100
#     max_idle_connections_percent = 50
#     connection_borrow_timeout    = 120
#   }
# }
#
# resource "aws_db_proxy_target" "main" {
#   db_cluster_identifier = aws_rds_cluster.main.cluster_identifier
#   db_proxy_name         = aws_db_proxy.main.name
#   target_group_name     = aws_db_proxy_default_target_group.main.name
# }

# IAM ROLE para RDS Proxy — deshabilitado junto con el proxy
# resource "aws_iam_role" "rds_proxy" {
#   name = "${local.name_prefix}-rds-proxy-role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "rds.amazonaws.com" } }]
#   })
#   tags = { Name = "${local.name_prefix}-rds-proxy-role" }
# }
#
# resource "aws_iam_role_policy" "rds_proxy" {
#   name = "${local.name_prefix}-rds-proxy-policy"
#   role = aws_iam_role.rds_proxy.id
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       { Effect = "Allow", Action = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"], Resource = [var.secret_rds_arn] },
#       { Effect = "Allow", Action = ["kms:Decrypt", "kms:GenerateDataKey"], Resource = [var.kms_key_arn] }
#     ]
#   })
# }

# ─────────────────────────────────────────────────────────────────────────────
# AWS BACKUP — Vault y plan de respaldo centralizado
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_backup_vault" "main" {
  name        = "${local.name_prefix}-backup-vault"
  kms_key_arn = var.kms_key_arn

  tags = {
    Name = "${local.name_prefix}-backup-vault"
  }
}

resource "aws_backup_plan" "main" {
  name = "${local.name_prefix}-backup-plan"

  rule {
    rule_name         = "backup-diario"
    target_vault_name = aws_backup_vault.main.name
    schedule          = "cron(0 5 * * ? *)"

    lifecycle {
      delete_after = var.aws_backup_retention_days
    }

    recovery_point_tags = {
      Environment = var.environment
      ManagedBy   = "aws-backup"
    }
  }

  tags = {
    Name = "${local.name_prefix}-backup-plan"
  }
}

resource "aws_iam_role" "aws_backup" {
  name = "${local.name_prefix}-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "backup.amazonaws.com" }
    }]
  })

  tags = {
    Name = "${local.name_prefix}-backup-role"
  }
}

resource "aws_iam_role_policy_attachment" "aws_backup" {
  role       = aws_iam_role.aws_backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_backup_selection" "rds" {
  name         = "${local.name_prefix}-backup-selection-rds"
  plan_id      = aws_backup_plan.main.id
  iam_role_arn = aws_iam_role.aws_backup.arn

  resources = [
    aws_db_instance.main.arn
  ]
}