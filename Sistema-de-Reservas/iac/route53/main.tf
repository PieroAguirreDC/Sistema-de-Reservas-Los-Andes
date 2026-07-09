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
  base_tags = merge({
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Module      = "route53"
  }, var.tags)
}

# ─────────────────────────────────────────────────────────────────────────────
# ROUTE 53 HOSTED ZONE
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_route53_zone" "main" {
  name = var.domain_name
  tags = local.base_tags
}

# ─────────────────────────────────────────────────────────────────────────────
# ALIAS RECORD TO CLOUDFRONT (A Record)
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_route53_record" "web" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = "Z2FDTNDATAQYW2" # ID de zona estático de CloudFront
    evaluate_target_health = false
  }
}
