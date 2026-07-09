variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "environment" {
  description = "Entorno de ejecución (dev, prod, etc.)"
  type        = string
}

variable "tags" {
  description = "Etiquetas a asociar a los recursos"
  type        = map(string)
  default     = {}
}
