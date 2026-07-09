variable "aws_region" {
  description = "Región AWS donde se despliega la VPC"
  type        = string
  default     = "us-east-2"
}

variable "project_name" {
  description = "Prefijo usado en el nombre de todos los recursos de red"
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

variable "tags" {
  description = "Tags adicionales a fusionar con los tags base del módulo"
  type        = map(string)
  default     = {}
}