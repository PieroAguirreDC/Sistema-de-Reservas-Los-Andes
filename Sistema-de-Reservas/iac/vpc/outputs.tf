# ─── VPC ──────────────────────────────────────────────────────────────────────
output "vpc_id" {
  description = "ID de la VPC — consumido por: alb, ecs-fargate, rds, elasticache, security"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR de la VPC — usado en reglas de SG de otros módulos"
  value       = aws_vpc.main.cidr_block
}

# ─── SUBREDES PÚBLICAS ────────────────────────────────────────────────────────
output "public_subnet_ids" {
  description = "IDs de subredes públicas — consumido por: alb"
  value       = aws_subnet.public[*].id
}

# ─── SUBREDES PRIVADAS DE APP ─────────────────────────────────────────────────
output "private_app_subnet_ids" {
  description = "IDs de subredes privadas de app — consumido por: ecs-fargate"
  value       = aws_subnet.private_app[*].id
}

output "private_app_cidrs" {
  description = "CIDRs de subredes de app — usado en reglas de SG de rds/elasticache"
  value       = [for s in aws_subnet.private_app : s.cidr_block]
}

# ─── SUBREDES PRIVADAS DE DB ──────────────────────────────────────────────────
output "private_db_subnet_ids" {
  description = "IDs de subredes privadas de DB — consumido por: rds, elasticache"
  value       = aws_subnet.private_db[*].id
}

# ─── AVAILABILITY ZONES ───────────────────────────────────────────────────────
output "availability_zones" {
  description = "AZs utilizadas — consumido por: rds (multi-az), elasticache"
  value       = local.azs
}

# ─── SECURITY GROUP DE ENDPOINTS ──────────────────────────────────────────────
output "sg_vpc_endpoints_id" {
  description = "SG de los VPC Endpoints — consumido por: ecs-fargate (para reglas de egress)"
  value       = aws_security_group.vpc_endpoints.id
}

# ─── VPC ENDPOINTS (IDs para referencia y dependencias) ───────────────────────
output "endpoint_s3_id" {
  description = "ID del VPC Gateway Endpoint de S3"
  value       = var.enable_vpc_endpoints ? aws_vpc_endpoint.s3[0].id : null
}

output "endpoint_ecr_api_id" {
  description = "ID del VPC Interface Endpoint de ECR API"
  value       = var.enable_vpc_endpoints ? aws_vpc_endpoint.ecr_api[0].id : null
}

output "endpoint_ecr_dkr_id" {
  description = "ID del VPC Interface Endpoint de ECR Docker"
  value       = var.enable_vpc_endpoints ? aws_vpc_endpoint.ecr_dkr[0].id : null
}