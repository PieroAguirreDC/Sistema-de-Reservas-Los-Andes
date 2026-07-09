output "cluster_arn" {
  description = "ARN del ECS Cluster — consumido por: monitoring, ci/cd"
  value       = aws_ecs_cluster.main.arn
}

output "cluster_name" {
  description = "Nombre del cluster — consumido por: ci/cd"
  value       = aws_ecs_cluster.main.name
}

output "usuarios_service_name" {
  description = "Nombre del servicio ECS de Usuarios"
  value       = aws_ecs_service.usuarios.name
}

output "habitaciones_service_name" {
  description = "Nombre del servicio ECS de Habitaciones"
  value       = aws_ecs_service.habitaciones.name
}

output "reservas_service_name" {
  description = "Nombre del servicio ECS de Reservas"
  value       = aws_ecs_service.reservas.name
}

output "pagos_service_name" {
  description = "Nombre del servicio ECS de Pagos"
  value       = aws_ecs_service.pagos.name
}

output "notificaciones_service_name" {
  description = "Nombre del servicio ECS de Notificaciones"
  value       = aws_ecs_service.notificaciones.name
}

output "web_service_name" {
  description = "Nombre del servicio Web — consumido por: ci/cd"
  value       = aws_ecs_service.web.name
}

output "execution_role_arn" {
  description = "ARN del execution role"
  value       = aws_iam_role.ecs_execution.arn
}