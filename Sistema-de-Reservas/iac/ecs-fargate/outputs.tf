output "cluster_arn" {
  description = "ARN del ECS Cluster — consumido por: monitoring, ci/cd"
  value       = aws_ecs_cluster.main.arn
}

output "cluster_name" {
  description = "Nombre del cluster — consumido por: ci/cd"
  value       = aws_ecs_cluster.main.name
}

output "api_service_name" {
  description = "Nombre del servicio API — consumido por: ci/cd"
  value       = aws_ecs_service.api.name
}

output "web_service_name" {
  description = "Nombre del servicio Web — consumido por: ci/cd"
  value       = aws_ecs_service.web.name
}

output "execution_role_arn" {
  description = "ARN del execution role"
  value       = aws_iam_role.ecs_execution.arn
}