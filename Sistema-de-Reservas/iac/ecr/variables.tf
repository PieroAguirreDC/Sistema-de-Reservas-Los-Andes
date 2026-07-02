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

variable "kms_key_arn" {
  description = "ARN de la clave KMS para cifrar repositorios ECR"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}