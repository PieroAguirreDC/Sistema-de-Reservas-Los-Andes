variable "aws_region" {
  description = "Región AWS donde se despliega"
  type        = string
  default     = "us-east-2"
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
  description = "ID de la VPC — viene de output del módulo vpc"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR de la VPC — usado en reglas de SG"
  type        = string
}

variable "private_app_cidrs" {
  description = "CIDRs de subredes de app — viene de output del módulo vpc"
  type        = list(string)
}

# ─── KMS ──────────────────────────────────────────────────────────────────────
variable "kms_deletion_window" {
  description = "Días antes de eliminar la clave KMS (7–30)"
  type        = number
  default     = 7

  validation {
    condition     = var.kms_deletion_window >= 7 && var.kms_deletion_window <= 30
    error_message = "El período de eliminación de KMS debe ser entre 7 y 30 días."
  }
}

variable "db_master_password" {
  description = "Contraseña maestra para la base de datos Aurora que se almacena en Secrets Manager"
  type        = string
}

variable "tags" {
  description = "Tags adicionales a fusionar con los tags base"
  type        = map(string)
  default     = {}
}
