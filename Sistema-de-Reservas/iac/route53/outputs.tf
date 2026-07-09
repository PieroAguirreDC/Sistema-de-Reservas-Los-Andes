output "zone_id" {
  description = "ID de la Hosted Zone creada"
  value       = aws_route53_zone.main.zone_id
}

output "name_servers" {
  description = "Lista de name servers de la Hosted Zone"
  value       = aws_route53_zone.main.name_servers
}
