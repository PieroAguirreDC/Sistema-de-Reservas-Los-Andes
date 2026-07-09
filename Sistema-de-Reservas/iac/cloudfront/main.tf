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
    Module      = "cloudfront"
  }, var.tags)

  s3_origin_id  = "S3-FrontendStatic"
  api_origin_id = "APIGateway-Backend"
}

# ─────────────────────────────────────────────────────────────────────────────
# ORIGIN ACCESS CONTROL (OAC) — Acceso seguro al bucket S3 sin hacerlo público
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "${local.name_prefix}-s3-oac"
  description                       = "OAC para bucket S3 de frontend de ${local.name_prefix}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# ─────────────────────────────────────────────────────────────────────────────
# CLOUDFRONT DISTRIBUTION
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_cloudfront_distribution" "main" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100" # Barato para dev (US/EU/CA)

  # --- ORIGEN 1: S3 (Frontend Estático) ---
  origin {
    domain_name              = var.frontend_bucket_domain_name
    origin_id                = local.s3_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
  }

  # --- ORIGEN 2: API Gateway (Backend) ---
  origin {
    domain_name = var.api_gateway_domain_name
    origin_id   = local.api_origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # --- COMPORTAMIENTO POR DEFECTO: S3 ---
  default_cache_behavior {
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  # --- COMPORTAMIENTO PARA API (/api/*) ---
  ordered_cache_behavior {
    path_pattern     = "/api/*"
    target_origin_id = local.api_origin_id
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD"]

    # Sin cachear API
    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0

    forwarded_values {
      query_string = true
      headers      = ["*"]
      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  # --- COMPORTAMIENTO PARA API V1 (/api/v1/*) ---
  ordered_cache_behavior {
    path_pattern     = "/api/v1/*"
    target_origin_id = local.api_origin_id
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD"]

    # Sin cachear API
    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0

    forwarded_values {
      query_string = true
      headers      = ["*"]
      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  # --- RESTRICCIONES ---
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # --- CERTIFICADO SSL ---
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  # Páginas de error personalizadas para SPA/Next.js
  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10
  }

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10
  }

  tags = local.base_tags
}

# ─────────────────────────────────────────────────────────────────────────────
# S3 BUCKET POLICY — Permite a CloudFront OAC leer el bucket estático
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_s3_bucket_policy" "cloudfront_read" {
  bucket = var.frontend_bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontOACRead"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${var.frontend_bucket_arn}/*"
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_cloudfront_distribution.main.arn
          }
        }
      }
    ]
  })
}
