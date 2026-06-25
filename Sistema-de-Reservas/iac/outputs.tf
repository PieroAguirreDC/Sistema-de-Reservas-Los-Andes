# ─── VPC ─────────────────────────────────────────────────────────────────────
output "vpc_id" {
  description = "ID de la VPC principal"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR de la VPC"
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "IDs de subredes públicas (para ALB)"
  value       = module.vpc.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "IDs de subredes privadas de app (para ECS)"
  value       = module.vpc.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  description = "IDs de subredes privadas de DB (para RDS y ElastiCache)"
  value       = module.vpc.private_db_subnet_ids
}

output "availability_zones" {
  description = "AZs utilizadas"
  value       = module.vpc.availability_zones
}

# ─── SECURITY ────────────────────────────────────────────────────────────────
output "kms_key_arn" {
  description = "ARN de la clave KMS principal"
  value       = module.security.kms_key_arn
}

output "secret_rds_arn" {
  description = "ARN del secreto de credenciales RDS"
  value       = module.security.secret_rds_arn
}

output "sg_alb_id" {
  description = "ID del Security Group del ALB"
  value       = module.security.sg_alb_id
}

output "sg_ecs_id" {
  description = "ID del Security Group de ECS"
  value       = module.security.sg_ecs_id
}

output "sg_rds_id" {
  description = "ID del Security Group de RDS"
  value       = module.security.sg_rds_id
}

# ─── RDS ─────────────────────────────────────────────────────────────────────
output "aurora_cluster_id" {
  description = "ID del cluster Aurora"
  value       = module.rds.aurora_cluster_id
}

output "rds_proxy_endpoint" {
  description = "Endpoint del RDS Proxy (usar este en las apps)"
  value       = module.rds.rds_proxy_endpoint
}

output "aurora_database_name" {
  description = "Nombre de la base de datos"
  value       = module.rds.aurora_database_name
}

# ─── ELASTICACHE ─────────────────────────────────────────────────────────────
output "redis_primary_endpoint" {
  description = "Endpoint primario de Redis"
  value       = module.elasticache.redis_primary_endpoint
}

# ─── MESSAGING ───────────────────────────────────────────────────────────────
output "sns_topic_reservas_arn" {
  description = "ARN del topic SNS de reservas"
  value       = module.messaging.sns_topic_reservas_arn
}

output "sns_topic_pagos_arn" {
  description = "ARN del topic SNS de pagos"
  value       = module.messaging.sns_topic_pagos_arn
}

output "sqs_reservas_pagos_url" {
  description = "URL de la cola SQS reservas-pagos"
  value       = module.messaging.sqs_reservas_pagos_url
}
