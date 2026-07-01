variable "aws_region" {
  description = "Región AWS donde se despliega todo el stack"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefijo usado en el nombre de todos los recursos"
  type        = string
  default     = "reservas"
}

variable "environment" {
  description = "Entorno de despliegue"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "Bloque CIDR raíz de la VPC para dev"
  type        = string
  default     = "10.0.0.0/16"
}

variable "certificate_arn" {
  description = "ARN del certificado ACM para HTTPS en el ALB (vacío = solo HTTP, válido para dev)"
  type        = string
  default     = ""
}

variable "alarm_email" {
  description = "Email que recibe las alarmas de CloudWatch"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags adicionales a fusionar con los tags base de cada módulo"
  type        = map(string)
  default     = {}
}
