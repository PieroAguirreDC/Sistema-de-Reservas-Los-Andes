variable "aws_region" {
  description = "Región AWS"
  type        = string
  default     = "us-east-2"
}

variable "project_name" {
  description = "Prefijo de recursos"
  type        = string
  default     = "reservas"
}

variable "environment" {
  description = "Entorno: dev | prod"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "El entorno debe ser 'dev' o 'prod'."
  }
}

variable "vpc_id" {
  description = "ID de la VPC — viene del módulo vpc"
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs de subnets públicas — viene del módulo vpc"
  type        = list(string)
}

variable "sg_alb_id" {
  description = "ID del Security Group del ALB — viene del módulo security"
  type        = string
}

variable "certificate_arn" {
  description = "ARN del certificado ACM para HTTPS"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags adicionales"
  type        = map(string)
  default     = {}
}