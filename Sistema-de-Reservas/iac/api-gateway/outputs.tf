output "api_endpoint" {
  description = "URL pública del API Gateway"
  value       = aws_apigatewayv2_stage.default.invoke_url
}

output "api_id" {
  description = "ID del API Gateway — consumido por: monitoring"
  value       = aws_apigatewayv2_api.main.id
}