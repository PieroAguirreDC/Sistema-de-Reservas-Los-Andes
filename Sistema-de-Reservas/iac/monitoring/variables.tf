variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "reservas"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "cluster_name" {
  description = "Nombre del ECS Cluster — viene del módulo ecs-fargate"
  type        = string
}

variable "usuarios_service_name" {
  description = "Nombre del servicio ECS de Usuarios"
  type        = string
}

variable "habitaciones_service_name" {
  description = "Nombre del servicio ECS de Habitaciones"
  type        = string
}

variable "reservas_service_name" {
  description = "Nombre del servicio ECS de Reservas"
  type        = string
}

variable "pagos_service_name" {
  description = "Nombre del servicio ECS de Pagos"
  type        = string
}

variable "notificaciones_service_name" {
  description = "Nombre del servicio ECS de Notificaciones"
  type        = string
}

variable "web_service_name" {
  description = "Nombre del servicio Web — viene del módulo ecs-fargate"
  type        = string
}

variable "alb_arn" {
  description = "ARN del ALB — viene del módulo alb"
  type        = string
}

variable "usuarios_target_group_arn" {
  description = "ARN del TG de la API de Usuarios — viene del módulo alb"
  type        = string
}

variable "alarm_email" {
  description = "Email para recibir alertas"
  type        = string
  default     = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}
variable "kms_key_arn" {
  description = "ARN de la KMS key para cifrar el SNS topic"
  type        = string
  default     = ""
}