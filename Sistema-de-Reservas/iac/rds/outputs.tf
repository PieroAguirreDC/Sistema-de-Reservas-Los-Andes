# ─── CLUSTER ──────────────────────────────────────────────────────────────────
output "aurora_cluster_id" {
  description = "ID del cluster Aurora — referencia general"
  value       = aws_rds_cluster.main.cluster_identifier
}

output "aurora_cluster_arn" {
  description = "ARN del cluster Aurora — consumido por: aws_backup_selection"
  value       = aws_rds_cluster.main.arn
}

# ─── ENDPOINTS ────────────────────────────────────────────────────────────────
output "aurora_endpoint_writer" {
  description = "Endpoint de escritura del cluster — consumido por: rds_proxy"
  value       = aws_rds_cluster.main.endpoint
}

output "aurora_endpoint_reader" {
  description = "Endpoint de lectura del cluster — consumido por: ecs-fargate (lecturas)"
  value       = aws_rds_cluster.main.reader_endpoint
}

output "rds_proxy_endpoint" {
  description = "Endpoint del RDS Proxy — consumido por: ecs-fargate (conexión principal)"
  value       = aws_db_proxy.main.endpoint
}

# ─── CONFIGURACIÓN ────────────────────────────────────────────────────────────
output "aurora_port" {
  description = "Puerto de Aurora PostgreSQL"
  value       = aws_rds_cluster.main.port
}

output "aurora_database_name" {
  description = "Nombre de la base de datos — consumido por: ecs-fargate (variables de entorno)"
  value       = aws_rds_cluster.main.database_name
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