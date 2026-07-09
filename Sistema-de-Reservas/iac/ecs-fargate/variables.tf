variable "aws_region" {
  description = "Región AWS"
  type        = string
  default     = "us-east-2"
}

variable "project_name" {
  type    = string
  default = "reservas"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "sg_ecs_id" {
  description = "Security Group para las tasks ECS"
  type        = string
}

variable "usuarios_target_group_arn" {
  description = "ARN del TG de la API de Usuarios"
  type        = string
}

variable "habitaciones_target_group_arn" {
  description = "ARN del TG de la API de Habitaciones"
  type        = string
}

variable "reservas_target_group_arn" {
  description = "ARN del TG de la API de Reservas"
  type        = string
}

variable "pagos_target_group_arn" {
  description = "ARN del TG de la API de Pagos"
  type        = string
}

variable "notificaciones_target_group_arn" {
  description = "ARN del TG de la API de Notificaciones"
  type        = string
}

variable "web_target_group_arn" {
  description = "ARN del TG del Web — viene del módulo alb"
  type        = string
}

variable "usuarios_image_uri" {
  description = "URI de la imagen de ECR de Usuarios"
  type        = string
}

variable "habitaciones_image_uri" {
  description = "URI de la imagen de ECR de Habitaciones"
  type        = string
}

variable "reservas_image_uri" {
  description = "URI de la imagen de ECR de Reservas"
  type        = string
}

variable "pagos_image_uri" {
  description = "URI de la imagen de ECR de Pagos"
  type        = string
}

variable "notificaciones_image_uri" {
  description = "URI de la imagen de ECR de Notificaciones"
  type        = string
}

variable "web_image_uri" {
  description = "URI completa de la imagen en ECR para el Web"
  type        = string
}

variable "api_cpu" {
  type    = number
  default = 256
}

variable "api_memory" {
  type    = number
  default = 512
}

variable "web_cpu" {
  type    = number
  default = 256
}

variable "web_memory" {
  type    = number
  default = 512
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "kms_key_arn" {
  description = "ARN de la KMS CMK para cifrar los log groups de ECS"
  type        = string
}
variable "rds_proxy_endpoint" {
  type = string
}

variable "aurora_database_name" {
  type = string
}

variable "aurora_port" {
  type    = number
  default = 5432
}

variable "secret_rds_arn" {
  type = string
}

variable "redis_primary_endpoint" {
  type = string
}

variable "redis_port" {
  type    = number
  default = 6379
}

variable "s3_bucket_public" {
  type = string
}

variable "s3_bucket_private" {
  type = string
}

variable "s3_uploads_policy_arn" {
  type = string
}

variable "sns_topic_reservas_arn" {
  type = string
}

variable "sns_topic_pagos_arn" {
  type = string
}

variable "sqs_reservas_notificaciones_arn" {
  type = string
}

variable "sqs_pagos_notificaciones_arn" {
  type = string
}

variable "sqs_reservas_pagos_arn" {
  type = string
}

variable "sqs_reservas_notificaciones_url" {
  type = string
}

variable "sqs_pagos_notificaciones_url" {
  type = string
}

variable "sqs_reservas_pagos_url" {
  type = string
}

variable "autoscale_min_capacity" {
  description = "Capacidad mínima de tareas para el auto-escalado"
  type        = number
  default     = 1
}

variable "autoscale_max_capacity" {
  description = "Capacidad máxima de tareas para el auto-escalado"
  type        = number
  default     = 3
}

variable "autoscale_target_cpu" {
  description = "Porcentaje de uso de CPU promedio objetivo para el auto-escalado"
  type        = number
  default     = 70
}