output "cloudfront_domain_name" {
  description = "Nombre de dominio público asignado a la distribución de CloudFront"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "cloudfront_distribution_id" {
  description = "ID de la distribución de CloudFront"
  value       = aws_cloudfront_distribution.main.id
}

output "cloudfront_arn" {
  description = "ARN de la distribución de CloudFront"
  value       = aws_cloudfront_distribution.main.arn
}
