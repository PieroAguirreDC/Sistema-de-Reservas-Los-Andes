variable "project_name" {
  description = "Prefijo usado en el nombre de todos los recursos"
  type        = string
}

variable "environment" {
  description = "Entorno de despliegue (dev/prod)"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN de la KMS key (del módulo security) usada para cifrar los buckets"
  type        = string
}

variable "allowed_upload_origins" {
  description = "Orígenes (dominios) permitidos en CORS para subir archivos directamente desde el navegador vía presigned URLs. Ej: [\"https://reservas.midominio.com\"]"
  type        = list(string)
}

variable "max_image_size_mb" {
  description = "Tamaño máximo permitido por imagen, en MB. Debe coincidir con el content-length-range configurado en el backend al generar presigned URLs."
  type        = number
  default     = 2
}

variable "max_pdf_size_mb" {
  description = "Tamaño máximo permitido por PDF, en MB. Debe coincidir con el content-length-range configurado en el backend al generar presigned URLs."
  type        = number
  default     = 5
}

variable "tags" {
  description = "Tags adicionales a fusionar con los tags base del módulo"
  type        = map(string)
  default     = {}
}
