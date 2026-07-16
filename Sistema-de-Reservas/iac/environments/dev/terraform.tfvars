# ─────────────────────────────────────────────────────────────────────────────
# terraform.tfvars — Ambiente: dev
# Valores públicos sin secretos.
# Los secretos (passwords, tokens) se inyectan vía variables de entorno:
#   export TF_VAR_db_master_password="tu-password-segura"
#   export TF_VAR_redis_auth_token="tu-token-redis-16chars"
# ─────────────────────────────────────────────────────────────────────────────

# ─── General ──────────────────────────────────────────────────────────────────
aws_region   = "us-east-2"
project_name = "reservas"
environment  = "dev"

# ─── Red ──────────────────────────────────────────────────────────────────────
vpc_cidr = "10.0.0.0/16"

# ─── ALB / HTTPS ──────────────────────────────────────────────────────────────
# Vacío en dev = solo HTTP. En producción colocar ARN del certificado ACM.
certificate_arn = ""

# ─── Monitoreo ────────────────────────────────────────────────────────────────
# Email para alarmas de CloudWatch (opcional en dev)
alarm_email = "rodrigo.baldeonj@gmail.com"

# ─── Tags adicionales ─────────────────────────────────────────────────────────
tags = {
  Owner   = "equipo-reservas"
  Project = "sistema-reservas-los-andes"
}
