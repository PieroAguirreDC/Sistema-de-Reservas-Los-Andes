# ─────────────────────────────────────────────────────────────────────────────
# terraform.tfvars — Valores públicos (sin secretos)
# ¡NUNCA añadas db_master_password ni redis_auth_token aquí!
# Esos se inyectan vía variables de entorno:
#   export TF_VAR_db_master_password="tu-password-segura"
#   export TF_VAR_redis_auth_token="tu-token-redis-16chars"
# ─────────────────────────────────────────────────────────────────────────────

aws_region   = "us-east-1"
project_name = "reservas"
environment  = "dev"

# VPC
vpc_cidr             = "10.0.0.0/16"
enable_vpc_endpoints = true

# KMS
kms_deletion_window = 7

# Aurora PostgreSQL
aurora_instance_class     = "db.t3.medium"
aurora_engine_version     = "15.3"
aurora_database_name      = "reservas_db"
aurora_port               = 5432
backup_retention_days     = 7
backup_window             = "03:00-04:00"
maintenance_window        = "sun:04:00-sun:05:00"
aws_backup_retention_days = 30

# Redis
redis_node_type      = "cache.t3.micro"
redis_engine_version = "7.0"

# Tags adicionales
tags = {
  Owner   = "equipo-reservas"
  Project = "sistema-reservas-los-andes"
}
