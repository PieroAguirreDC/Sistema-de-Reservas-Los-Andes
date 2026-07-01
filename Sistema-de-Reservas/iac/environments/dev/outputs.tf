# ─── RED ──────────────────────────────────────────────────────────────────────
output "vpc_id" {
  value = module.vpc.vpc_id
}

# ─── BASE DE DATOS ────────────────────────────────────────────────────────────
output "aurora_endpoint_writer" {
  value = module.rds.aurora_endpoint_writer
}

output "rds_proxy_endpoint" {
  value = module.rds.rds_proxy_endpoint
}

output "secret_rds_name" {
  description = "Nombre del secreto en Secrets Manager — úsalo desde la app para leer las credenciales"
  value       = module.security.secret_rds_name
}

# ─── CACHE ────────────────────────────────────────────────────────────────────
output "redis_primary_endpoint" {
  value = module.elasticache.redis_primary_endpoint
}

# ─── MENSAJERÍA ───────────────────────────────────────────────────────────────
output "sns_topic_reservas_arn" {
  value = module.messaging.sns_topic_reservas_arn
}

output "sqs_reservas_pagos_url" {
  value = module.messaging.sqs_reservas_pagos_url
}

# ─── CONTENEDORES ─────────────────────────────────────────────────────────────
output "ecr_api_repository_url" {
  value = module.ecr.api_repository_url
}

output "ecr_web_repository_url" {
  value = module.ecr.web_repository_url
}

# ─── EXPOSICIÓN ───────────────────────────────────────────────────────────────
output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "api_gateway_endpoint" {
  value = module.api_gateway.api_endpoint
}

# ─── OBSERVABILIDAD ───────────────────────────────────────────────────────────
output "cloudwatch_dashboard_name" {
  value = module.monitoring.dashboard_name
}
