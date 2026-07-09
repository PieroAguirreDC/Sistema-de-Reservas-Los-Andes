variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "environment" {
  description = "Entorno (dev, prod, etc.)"
  type        = string
}

variable "domain_name" {
  description = "Nombre de dominio para la Hosted Zone de Route 53 (ej. reservas-dev.local)"
  type        = string
  default     = "reservas-dev.local"
}

variable "cloudfront_domain_name" {
  description = "Domain name de la distribución de CloudFront"
  type        = string
}

variable "tags" {
  description = "Etiquetas para los recursos"
  type        = map(string)
  default     = {}
}
