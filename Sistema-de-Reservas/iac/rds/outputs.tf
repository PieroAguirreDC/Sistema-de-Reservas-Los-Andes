# ─── INSTANCIA ────────────────────────────────────────────────────────────────
output "aurora_cluster_id" {
  description = "Identifier de la instancia RDS PostgreSQL"
  value       = aws_db_instance.main.identifier
}

output "aurora_cluster_arn" {
  description = "ARN de la instancia RDS — consumido por: aws_backup_selection"
  value       = aws_db_instance.main.arn
}

# ─── ENDPOINTS ────────────────────────────────────────────────────────────────
output "aurora_endpoint_writer" {
  description = "Hostname del endpoint RDS — consumido por: ecs-fargate"
  value       = aws_db_instance.main.address
}

output "aurora_endpoint_reader" {
  description = "Hostname del endpoint RDS (instancia única, mismo que writer)"
  value       = aws_db_instance.main.address
}

output "rds_proxy_endpoint" {
  description = "Endpoint de conexión a la BD — usa RDS directamente (RDS Proxy deshabilitado en free tier)"
  value       = aws_db_instance.main.address
}

# ─── CONFIGURACIÓN ────────────────────────────────────────────────────────────
output "aurora_port" {
  description = "Puerto de RDS PostgreSQL"
  value       = aws_db_instance.main.port
}

output "aurora_database_name" {
  description = "Nombre de la base de datos — consumido por: ecs-fargate (variables de entorno)"
  value       = aws_db_instance.main.db_name
}

# ─── BACKUP ───────────────────────────────────────────────────────────────────
output "backup_vault_arn" {
  description = "ARN del vault de AWS Backup"
  value       = aws_backup_vault.main.arn
}

output "backup_plan_id" {
  description = "ID del plan de AWS Backup"
  value       = aws_backup_plan.main.id
}