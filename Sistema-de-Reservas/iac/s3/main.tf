terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  base_tags = merge({
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Module      = "s3"
  }, var.tags)
}

# ═════════════════════════════════════════════════════════════════════════════
# BUCKET 1 — FRONTEND ESTÁTICO
# Solo lo escribe el pipeline de CI/CD (build de Next.js export). Lectura
# pública vía CloudFront (no directo a S3).
# ═════════════════════════════════════════════════════════════════════════════
resource "aws_s3_bucket" "frontend_static" {
  bucket = "${local.name_prefix}-frontend-static"
  tags   = local.base_tags
}

resource "aws_s3_bucket_versioning" "frontend_static" {
  bucket = aws_s3_bucket.frontend_static.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "frontend_static" {
  bucket = aws_s3_bucket.frontend_static.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "frontend_static" {
  bucket                  = aws_s3_bucket.frontend_static.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ═════════════════════════════════════════════════════════════════════════════
# BUCKET 2 — UPLOADS PÚBLICOS
# Imágenes de habitaciones/catálogo. Solo el admin (backend con rol) escribe;
# lectura pública vía CloudFront.
# ═════════════════════════════════════════════════════════════════════════════
resource "aws_s3_bucket" "uploads_public" {
  bucket = "${local.name_prefix}-uploads-public"
  tags   = local.base_tags
}

resource "aws_s3_bucket_versioning" "uploads_public" {
  bucket = aws_s3_bucket.uploads_public.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "uploads_public" {
  bucket = aws_s3_bucket.uploads_public.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "uploads_public" {
  bucket                  = aws_s3_bucket.uploads_public.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  # El acceso público real se sirve por CloudFront (OAC), no por ACL/policy
  # directa del bucket. Se mantiene bloqueado por seguridad.
}

resource "aws_s3_bucket_cors_configuration" "uploads_public" {
  bucket = aws_s3_bucket.uploads_public.id

  cors_rule {
    allowed_methods = ["PUT", "POST"]
    allowed_origins = var.allowed_upload_origins
    allowed_headers = ["*"]
    max_age_seconds = 3000
  }
}

# Lifecycle: archivos huérfanos (subida iniciada pero nunca confirmada por la
# app) se limpian a los 1 día para no acumular basura.
resource "aws_s3_bucket_lifecycle_configuration" "uploads_public" {
  bucket = aws_s3_bucket.uploads_public.id

  rule {
    id     = "abort-incomplete-multipart-uploads"
    status = "Enabled"
    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}

# ═════════════════════════════════════════════════════════════════════════════
# BUCKET 3 — UPLOADS PRIVADOS
# Comprobantes de pago, fotos de perfil. Nunca público — solo vía URLs
# firmadas (presigned GET) con expiración corta, generadas por el backend.
# ═════════════════════════════════════════════════════════════════════════════
resource "aws_s3_bucket" "uploads_private" {
  bucket = "${local.name_prefix}-uploads-private"
  tags   = local.base_tags
}

resource "aws_s3_bucket_versioning" "uploads_private" {
  bucket = aws_s3_bucket.uploads_private.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "uploads_private" {
  bucket = aws_s3_bucket.uploads_private.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "uploads_private" {
  bucket                  = aws_s3_bucket.uploads_private.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_cors_configuration" "uploads_private" {
  bucket = aws_s3_bucket.uploads_private.id

  cors_rule {
    allowed_methods = ["PUT", "POST", "GET"]
    allowed_origins = var.allowed_upload_origins
    allowed_headers = ["*"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "uploads_private" {
  bucket = aws_s3_bucket.uploads_private.id

  rule {
    id     = "abort-incomplete-multipart-uploads"
    status = "Enabled"
    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }

  # Comprobantes de pago: mover a Infrequent Access luego de 90 días
  # (se consultan poco después de confirmada la reserva, pero deben
  # conservarse por temas contables/legales).
  rule {
    id     = "transition-old-receipts"
    status = "Enabled"
    filter {
      prefix = "comprobantes-pago/"
    }
    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }
  }
}

# ═════════════════════════════════════════════════════════════════════════════
# POLÍTICA DE VALIDACIÓN DE TAMAÑO/TIPO — vía IAM policy que restringe
# el presigned POST que genera el backend.
# El límite real de bytes se aplica en el propio presigned POST
# (content-length-range), generado dinámicamente por NestJS. Esta policy
# solo acota qué prefijos/Content-Type puede escribir el rol del backend,
# como defensa en profundidad.
# ═════════════════════════════════════════════════════════════════════════════
data "aws_iam_policy_document" "backend_uploads_access" {
  statement {
    sid    = "AllowPutPublicImages"
    effect = "Allow"
    actions = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.uploads_public.arn}/*"]
    condition {
      test     = "StringLike"
      variable = "s3:content-type"
      values   = ["image/jpeg", "image/png", "image/webp"]
    }
  }

  statement {
    sid    = "AllowPutPrivateFiles"
    effect = "Allow"
    actions = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.uploads_private.arn}/*"]
    condition {
      test     = "StringLike"
      variable = "s3:content-type"
      values   = ["image/jpeg", "image/png", "image/webp", "application/pdf"]
    }
  }

  statement {
    sid       = "AllowGetPrivateFiles"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.uploads_private.arn}/*"]
  }

  statement {
    sid       = "AllowGetPublicImages"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.uploads_public.arn}/*"]
  }
}

resource "aws_iam_policy" "backend_uploads_access" {
  name        = "${local.name_prefix}-s3-uploads-access"
  description = "Permisos del backend (ECS task role) para subir/leer en los buckets de uploads, restringido por content-type"
  policy      = data.aws_iam_policy_document.backend_uploads_access.json
  tags        = local.base_tags
}
