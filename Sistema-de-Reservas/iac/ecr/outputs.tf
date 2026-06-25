output "api_repository_url" {
  description = "URL del repo ECR API — consumido por: ecs-fargate, ci/cd"
  value       = aws_ecr_repository.api.repository_url
}

output "web_repository_url" {
  description = "URL del repo ECR Web — consumido por: ecs-fargate, ci/cd"
  value       = aws_ecr_repository.web.repository_url
}

output "api_repository_arn" {
  description = "ARN del repo ECR API"
  value       = aws_ecr_repository.api.arn
}

output "web_repository_arn" {
  description = "ARN del repo ECR Web"
  value       = aws_ecr_repository.web.arn
}