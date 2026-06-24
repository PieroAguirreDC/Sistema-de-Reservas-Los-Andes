variable "aws_region" {
  description = "Región AWS donde se despliega"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefijo usado en el nombre de todos los recursos"
  type        = string
  default     = "reservas"
}

variable "environment" {
  description = "Entorno de despliegue: dev | prod"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "El entorno debe ser 'dev' o 'prod'."
  }
}

# ─── INPUTS DESDE MÓDULO VPC ──────────────────────────────────────────────────
variable "vpc_id" {
  description = "ID de la VPC — viene del módulo vpc"
  type        = string
}

variable "private_db_subnet_ids" {
  description = "IDs de subredes privadas de DB — viene del módulo vpc"
  type        = list(string)
}

variable "availability_zones" {
  description = "AZs utilizadas — viene del módulo vpc"
  type        = list(string)
}

# ─── INPUTS DESDE MÓDULO SECURITY ─────────────────────────────────────────────
variable "kms_key_arn" {
  description = "ARN de la clave KMS — viene del módulo security"
  type        = string
}

variable "sg_rds_id" {
  description = "ID del Security Group de RDS — viene del módulo security"
  type        = string
}

variable "secret_rds_arn" {
  description = "ARN del secreto de credenciales RDS — viene del módulo security"
  type        = string
}

# ─── AURORA ───────────────────────────────────────────────────────────────────
variable "aurora_instance_class" {
  description = "Tipo de instancia Aurora (dev: db.t3.medium | prod: db.r6g.large)"
  type        = string
  default     = "db.t3.medium"
}

variable "aurora_engine_version" {
  description = "Versión del motor Aurora PostgreSQL"
  type        = string
  default     = "15.4"
}

variable "aurora_database_name" {
  description = "Nombre de la base de datos inicial"
  type        = string
  default     = "reservas_db"
}

variable "aurora_port" {
  description = "Puerto de Aurora PostgreSQL"
  type        = number
  default     = 5432
}

# ─── BACKUP ───────────────────────────────────────────────────────────────────
variable "backup_retention_days" {
  description = "Días de retención del backup automático de Aurora (1-35)"
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_days >= 1 && var.backup_retention_days <= 35
    error_message = "El período de retención debe ser entre 1 y 35 días."
  }
}

variable "backup_window" {
  description = "Ventana de backup diario en UTC (formato hh:mm-hh:mm)"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Ventana de mantenimiento semanal (formato ddd:hh:mm-ddd:hh:mm)"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "aws_backup_retention_days" {
  description = "Días de retención en AWS Backup (mayor que el backup nativo de Aurora)"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags adicionales a fusionar con los tags base"
  type        = map(string)
  default     = {}
}

variable "db_master_password" {
  description = "Contraseña maestra de Aurora — viene de Secrets Manager vía environments"
  type        = string
  sensitive   = true
}