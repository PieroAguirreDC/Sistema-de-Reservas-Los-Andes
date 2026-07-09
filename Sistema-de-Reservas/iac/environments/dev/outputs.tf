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
output "ecr_usuarios_repository_url" {
  value = module.ecr.usuarios_repository_url
}

output "ecr_habitaciones_repository_url" {
  value = module.ecr.habitaciones_repository_url
}

output "ecr_reservas_repository_url" {
  value = module.ecr.reservas_repository_url
}

output "ecr_pagos_repository_url" {
  value = module.ecr.pagos_repository_url
}

output "ecr_notificaciones_repository_url" {
  value = module.ecr.notificaciones_repository_url
}

output "ecr_web_repository_url" {
  value = module.ecr.web_repository_url
}

# ─── EXPOSICIÓN Y CDN ─────────────────────────────────────────────────────────
output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "api_gateway_endpoint" {
  value = module.api_gateway.api_endpoint
}

output "cloudfront_domain_name" {
  value = module.cloudfront.cloudfront_domain_name
}

# ─── COGNITO ──────────────────────────────────────────────────────────────────
output "cognito_user_pool_id" {
  value = module.cognito.user_pool_id
}

output "cognito_user_pool_client_id" {
  value = module.cognito.user_pool_client_id
}

output "cognito_user_pool_domain" {
  value = module.cognito.user_pool_domain
}

# ─── ROUTE 53 ─────────────────────────────────────────────────────────────────
output "route53_zone_id" {
  value = module.route53.zone_id
}

output "route53_name_servers" {
  value = module.route53.name_servers
}

# ─── OBSERVABILIDAD ───────────────────────────────────────────────────────────
output "cloudwatch_dashboard_name" {
  value = module.monitoring.dashboard_name
}
