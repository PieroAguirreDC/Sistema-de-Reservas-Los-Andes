output "user_pool_id" {
  description = "ID del User Pool de Cognito"
  value       = aws_cognito_user_pool.main.id
}

output "user_pool_arn" {
  description = "ARN del User Pool de Cognito"
  value       = aws_cognito_user_pool.main.arn
}

output "user_pool_client_id" {
  description = "ID del User Pool Client de Cognito"
  value       = aws_cognito_user_pool_client.main.id
}

output "user_pool_domain" {
  description = "Dominio de Cognito configurado para Hosted UI"
  value       = aws_cognito_user_pool_domain.main.domain
}
