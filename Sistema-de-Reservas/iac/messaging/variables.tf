variable "aws_region" {
  description = "Región AWS donde se despliegan los recursos"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nombre del proyecto, usado como prefijo en los recursos"
  type        = string
}

variable "environment" {
  description = "Entorno de despliegue (dev, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "El entorno debe ser 'dev' o 'prod'."
  }
}

variable "kms_key_arn" {
  description = "ARN de la clave KMS del módulo security para cifrar SNS y SQS"
  type        = string
}

variable "tags" {
  description = "Tags adicionales a aplicar a todos los recursos"
  type        = map(string)
  default     = {}
}