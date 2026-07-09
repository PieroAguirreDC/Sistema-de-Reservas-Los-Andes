output "usuarios_repository_url" {
  description = "URL del repo ECR de Usuarios"
  value       = aws_ecr_repository.usuarios.repository_url
}

output "habitaciones_repository_url" {
  description = "URL del repo ECR de Habitaciones"
  value       = aws_ecr_repository.habitaciones.repository_url
}

output "reservas_repository_url" {
  description = "URL del repo ECR de Reservas"
  value       = aws_ecr_repository.reservas.repository_url
}

output "pagos_repository_url" {
  description = "URL del repo ECR de Pagos"
  value       = aws_ecr_repository.pagos.repository_url
}

output "notificaciones_repository_url" {
  description = "URL del repo ECR de Notificaciones"
  value       = aws_ecr_repository.notificaciones.repository_url
}

output "web_repository_url" {
  description = "URL del repo ECR Web — consumido por: ecs-fargate, ci/cd"
  value       = aws_ecr_repository.web.repository_url
}

output "usuarios_repository_arn" {
  description = "ARN del repo ECR de Usuarios"
  value       = aws_ecr_repository.usuarios.arn
}

output "habitaciones_repository_arn" {
  description = "ARN del repo ECR de Habitaciones"
  value       = aws_ecr_repository.habitaciones.arn
}

output "reservas_repository_arn" {
  description = "ARN del repo ECR de Reservas"
  value       = aws_ecr_repository.reservas.arn
}

output "pagos_repository_arn" {
  description = "ARN del repo ECR de Pagos"
  value       = aws_ecr_repository.pagos.arn
}

output "notificaciones_repository_arn" {
  description = "ARN del repo ECR de Notificaciones"
  value       = aws_ecr_repository.notificaciones.arn
}

output "web_repository_arn" {
  description = "ARN del repo ECR Web"
  value       = aws_ecr_repository.web.arn
}