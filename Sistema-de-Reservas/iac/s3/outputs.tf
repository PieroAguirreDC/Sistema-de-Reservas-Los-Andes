# ─── FRONTEND ESTÁTICO ────────────────────────────────────────────────────────
output "frontend_static_bucket_name" {
  description = "Consumido por: pipeline CI/CD (destino del build de Next.js export) y por el módulo cloudfront/cdn si se agrega más adelante"
  value       = aws_s3_bucket.frontend_static.id
}

output "frontend_static_bucket_arn" {
  value = aws_s3_bucket.frontend_static.arn
}

# ─── UPLOADS PÚBLICOS (imágenes de habitaciones/catálogo) ────────────────────
output "uploads_public_bucket_name" {
  description = "Consumido por: apps/api (NestJS) para generar presigned POST de subida de imágenes"
  value       = aws_s3_bucket.uploads_public.id
}

output "uploads_public_bucket_arn" {
  value = aws_s3_bucket.uploads_public.arn
}

# ─── UPLOADS PRIVADOS (comprobantes de pago, fotos de perfil) ────────────────
output "uploads_private_bucket_name" {
  description = "Consumido por: apps/api (NestJS) para generar presigned POST/GET de archivos privados"
  value       = aws_s3_bucket.uploads_private.id
}

output "uploads_private_bucket_arn" {
  value = aws_s3_bucket.uploads_private.arn
}

# ─── PERMISOS ─────────────────────────────────────────────────────────────────
output "backend_uploads_policy_arn" {
  description = "Consumido por: ecs-fargate (debe adjuntarse al task role de la API para que NestJS pueda leer/escribir en los buckets de uploads)"
  value       = aws_iam_policy.backend_uploads_access.arn
}

# ─── LÍMITES (para que el backend valide de forma consistente con S3) ────────
output "max_image_size_bytes" {
  description = "Consumido por: apps/api al configurar content-length-range en los presigned POST de imágenes"
  value       = var.max_image_size_mb * 1024 * 1024
}

output "max_pdf_size_bytes" {
  description = "Consumido por: apps/api al configurar content-length-range en los presigned POST de PDFs"
  value       = var.max_pdf_size_mb * 1024 * 1024
}

output "frontend_static_bucket_regional_domain_name" {
  description = "Nombre de dominio regional del bucket S3 de frontend estático"
  value       = aws_s3_bucket.frontend_static.bucket_regional_domain_name
}
