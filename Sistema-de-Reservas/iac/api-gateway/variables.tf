variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "project_name" {
  type    = string
  default = "reservas"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "alb_dns_name" {
  description = "DNS del ALB — viene del módulo alb"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN de la clave KMS para cifrar los logs de CloudWatch"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}