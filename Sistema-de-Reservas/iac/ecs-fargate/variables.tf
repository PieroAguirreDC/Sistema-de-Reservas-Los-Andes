variable "aws_region" {
  description = "Región AWS"
  type        = string
  default     = "us-east-1"
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

variable "api_target_group_arn" {
  description = "ARN del TG de la API — viene del módulo alb"
  type        = string
}

variable "web_target_group_arn" {
  description = "ARN del TG del Web — viene del módulo alb"
  type        = string
}

variable "api_image_uri" {
  description = "URI completa de la imagen en ECR para la API"
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