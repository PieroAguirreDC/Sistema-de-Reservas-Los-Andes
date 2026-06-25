# ─── GLOBALS ─────────────────────────────────────────────────────────────────
variable "aws_region" {
  description = "Región AWS donde se despliega toda la infraestructura"
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

variable "tags" {
  description = "Tags adicionales a fusionar con los tags base"
  type        = map(string)
  default     = {}
}

# ─── VPC ─────────────────────────────────────────────────────────────────────
variable "vpc_cidr" {
  description = "Bloque CIDR raíz de la VPC (ej. 10.0.0.0/16)"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr debe ser un CIDR IPv4 válido."
  }
}

variable "enable_vpc_endpoints" {
  description = "Crea VPC Endpoints para ECR, S3, SSM y Secrets Manager"
  type        = bool
  default     = true
}

# ─── SECURITY / KMS ──────────────────────────────────────────────────────────
variable "kms_deletion_window" {
  description = "Días antes de eliminar la clave KMS (7-30)"
  type        = number
  default     = 7

  validation {
    condition     = var.kms_deletion_window >= 7 && var.kms_deletion_window <= 30
    error_message = "El período de eliminación de KMS debe ser entre 7 y 30 días."
  }
}

# ─── RDS AURORA ──────────────────────────────────────────────────────────────
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
  description = "Ventana de mantenimiento semanal"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "aws_backup_retention_days" {
  description = "Días de retención en AWS Backup"
  type        = number
  default     = 30
}

variable "db_master_password" {
  description = "Contraseña maestra de Aurora — inyectar vía TF_VAR_db_master_password, NUNCA en tfvars"
  type        = string
  sensitive   = true
}

# ─── ELASTICACHE / REDIS ──────────────────────────────────────────────────────
variable "redis_node_type" {
  description = "Tipo de nodo Redis (dev: cache.t3.micro | prod: cache.r6g.large)"
  type        = string
  default     = "cache.t3.micro"
}

variable "redis_engine_version" {
  description = "Versión del motor Redis"
  type        = string
  default     = "7.0"
}

variable "redis_auth_token" {
  description = "Token de autenticación para Redis (mín. 16 chars) — inyectar vía TF_VAR_redis_auth_token"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.redis_auth_token) >= 16
    error_message = "El redis_auth_token debe tener al menos 16 caracteres."
  }
}
