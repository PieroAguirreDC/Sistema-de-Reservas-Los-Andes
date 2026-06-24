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
variable "sg_elasticache_id" {
  description = "ID del Security Group de ElastiCache — viene del módulo security"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN de la clave KMS — viene del módulo security"
  type        = string
}

# ─── ELASTICACHE ──────────────────────────────────────────────────────────────
variable "node_type" {
  description = "Tipo de nodo Redis (dev: cache.t3.micro | prod: cache.r6g.large)"
  type        = string
  default     = "cache.t3.micro"
}

variable "redis_engine_version" {
  description = "Versión del motor Redis"
  type        = string
  default     = "7.0"
}

variable "tags" {
  description = "Tags adicionales a fusionar con los tags base"
  type        = map(string)
  default     = {}
}