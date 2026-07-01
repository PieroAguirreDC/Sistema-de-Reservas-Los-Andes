output "redis_primary_endpoint" {
  description = "Endpoint primario de Redis — consumido por: ecs-fargate"
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "redis_reader_endpoint" {
  description = "Endpoint de lectura de Redis — consumido por: ecs-fargate"
  value       = aws_elasticache_replication_group.main.reader_endpoint_address
}

output "redis_port" {
  description = "Puerto de Redis"
  value       = aws_elasticache_replication_group.main.port
}

output "replication_group_id" {
  description = "ID del replication group — consumido por: monitoring"
  value       = aws_elasticache_replication_group.main.id
}