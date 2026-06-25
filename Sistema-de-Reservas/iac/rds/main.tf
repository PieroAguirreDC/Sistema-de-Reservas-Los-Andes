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
# PARAMETER GROUP — Configuración del motor PostgreSQL
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_rds_cluster_parameter_group" "main" {
  name        = "${local.name_prefix}-aurora-params"
  family      = "aurora-postgresql15"
  description = "Parámetros del cluster Aurora PostgreSQL para ${local.name_prefix}"

  parameter {
    name  = "log_statement"
    value = "all"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }

  tags = {
    Name = "${local.name_prefix}-aurora-params"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# AURORA CLUSTER — Primary + Standby (Multi-AZ)
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_rds_cluster" "main" {
  cluster_identifier = "${local.name_prefix}-aurora-cluster"
  engine             = "aurora-postgresql"
  engine_version     = var.aurora_engine_version
  database_name      = var.aurora_database_name
  port               = var.aurora_port

  # Credenciales desde Secrets Manager
  master_username = "admin_${var.project_name}"
  master_password = var.db_master_password

  # Red
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.sg_rds_id]

  # Cifrado
  storage_encrypted = true
  kms_key_id        = var.kms_key_arn

  # CKV_AWS_162: Autenticación IAM habilitada (más segura que solo credenciales estáticas)
  iam_database_authentication_enabled = true

  # CKV_AWS_324: Exportar logs a CloudWatch
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  # Backup automático nativo de Aurora
  backup_retention_period = var.backup_retention_days
  preferred_backup_window = var.backup_window

  # CKV_AWS_313: Copiar tags del cluster a los snapshots
  copy_tags_to_snapshot = true

  # Mantenimiento
  preferred_maintenance_window = var.maintenance_window

  # Parámetros
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.main.name

  # CKV_AWS_139: Protección contra eliminación accidental (siempre activa)
  deletion_protection       = true
  skip_final_snapshot       = var.environment == "prod" ? false : true
  final_snapshot_identifier = var.environment == "prod" ? "${local.name_prefix}-final-snapshot" : null

  tags = {
    Name = "${local.name_prefix}-aurora-cluster"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# INSTANCIA PRIMARY — Escritura (us-east-1a)
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_rds_cluster_instance" "primary" {
  identifier         = "${local.name_prefix}-aurora-primary"
  cluster_identifier = aws_rds_cluster.main.id
  instance_class     = var.aurora_instance_class
  engine             = aws_rds_cluster.main.engine
  engine_version     = aws_rds_cluster.main.engine_version

  availability_zone            = var.availability_zones[0]
  db_subnet_group_name         = aws_db_subnet_group.main.name
  auto_minor_version_upgrade   = true
  performance_insights_enabled = true

  # CKV_AWS_354: Performance Insights cifrado con KMS CMK
  performance_insights_kms_key_id = var.kms_key_arn

  # CKV_AWS_118: Enhanced Monitoring cada 60 segundos
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_enhanced_monitoring.arn

  tags = {
    Name = "${local.name_prefix}-aurora-primary"
    Role = "primary"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# INSTANCIA STANDBY — Solo lectura (us-east-1b)
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_rds_cluster_instance" "standby" {
  identifier         = "${local.name_prefix}-aurora-standby"
  cluster_identifier = aws_rds_cluster.main.id
  instance_class     = var.aurora_instance_class
  engine             = aws_rds_cluster.main.engine
  engine_version     = aws_rds_cluster.main.engine_version

  availability_zone            = var.availability_zones[1]
  db_subnet_group_name         = aws_db_subnet_group.main.name
  auto_minor_version_upgrade   = true
  performance_insights_enabled = true

  # CKV_AWS_354: Performance Insights cifrado con KMS CMK
  performance_insights_kms_key_id = var.kms_key_arn

  # CKV_AWS_118: Enhanced Monitoring cada 60 segundos
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_enhanced_monitoring.arn

  tags = {
    Name = "${local.name_prefix}-aurora-standby"
    Role = "standby-readonly"
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
# RDS PROXY — Pool de conexiones entre ECS y Aurora
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_db_proxy" "main" {
  name                   = "${local.name_prefix}-rds-proxy"
  debug_logging          = false
  engine_family          = "POSTGRESQL"
  idle_client_timeout    = 1800
  require_tls            = true
  role_arn               = aws_iam_role.rds_proxy.arn
  vpc_security_group_ids = [var.sg_rds_id]
  vpc_subnet_ids         = var.private_db_subnet_ids

  auth {
    auth_scheme = "SECRETS"
    iam_auth    = "DISABLED"
    secret_arn  = var.secret_rds_arn
  }

  tags = {
    Name = "${local.name_prefix}-rds-proxy"
  }
}

resource "aws_db_proxy_default_target_group" "main" {
  db_proxy_name = aws_db_proxy.main.name

  connection_pool_config {
    max_connections_percent      = 100
    max_idle_connections_percent = 50
    connection_borrow_timeout    = 120
  }
}

resource "aws_db_proxy_target" "main" {
  db_cluster_identifier = aws_rds_cluster.main.cluster_identifier
  db_proxy_name         = aws_db_proxy.main.name
  target_group_name     = aws_db_proxy_default_target_group.main.name
}

# ─────────────────────────────────────────────────────────────────────────────
# IAM ROLE — Permite a RDS Proxy leer el secreto de Secrets Manager
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_iam_role" "rds_proxy" {
  name = "${local.name_prefix}-rds-proxy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "rds.amazonaws.com" }
    }]
  })

  tags = {
    Name = "${local.name_prefix}-rds-proxy-role"
  }
}

resource "aws_iam_role_policy" "rds_proxy" {
  name = "${local.name_prefix}-rds-proxy-policy"
  role = aws_iam_role.rds_proxy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [var.secret_rds_arn]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = [var.kms_key_arn]
      }
    ]
  })
}

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
    aws_rds_cluster.main.arn
  ]
}