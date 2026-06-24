# ─── KMS ──────────────────────────────────────────────────────────────────────
output "kms_key_arn" {
  description = "ARN de la clave KMS — consumido por: rds, elasticache, secrets"
  value       = aws_kms_key.main.arn
}

output "kms_key_id" {
  description = "ID de la clave KMS"
  value       = aws_kms_key.main.key_id
}

output "kms_alias_arn" {
  description = "ARN del alias KMS"
  value       = aws_kms_alias.main.arn
}

# ─── SECRETS MANAGER ──────────────────────────────────────────────────────────
output "secret_rds_arn" {
  description = "ARN del secreto de RDS — consumido por: rds, ecs-fargate"
  value       = aws_secretsmanager_secret.rds_credentials.arn
}

output "secret_rds_name" {
  description = "Nombre del secreto RDS — usado para referenciar en task definitions"
  value       = aws_secretsmanager_secret.rds_credentials.name
}

# ─── SECURITY GROUPS ──────────────────────────────────────────────────────────
output "sg_alb_id" {
  description = "ID del SG del ALB — consumido por: alb"
  value       = aws_security_group.alb.id
}

output "sg_ecs_id" {
  description = "ID del SG de ECS — consumido por: ecs-fargate"
  value       = aws_security_group.ecs.id
}

output "sg_rds_id" {
  description = "ID del SG de RDS — consumido por: rds"
  value       = aws_security_group.rds.id
}

output "sg_elasticache_id" {
  description = "ID del SG de ElastiCache — consumido por: elasticache"
  value       = aws_security_group.elasticache.id
}