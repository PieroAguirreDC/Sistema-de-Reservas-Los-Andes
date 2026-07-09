variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "environment" {
  description = "Entorno (dev, prod, etc.)"
  type        = string
}

variable "frontend_bucket_id" {
  description = "ID/Nombre del bucket S3 de frontend estático"
  type        = string
}

variable "frontend_bucket_arn" {
  description = "ARN del bucket S3 de frontend estático"
  type        = string
}

variable "frontend_bucket_domain_name" {
  description = "Domain name regional del bucket S3 de frontend estático"
  type        = string
}

variable "api_gateway_domain_name" {
  description = "Domain name de la API Gateway (sin el protocolo https://)"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN de la llave KMS para encriptar logs (si aplica)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Etiquetas para los recursos"
  type        = map(string)
  default     = {}
}
