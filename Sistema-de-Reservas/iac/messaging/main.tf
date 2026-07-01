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
    Module      = "messaging"
  }, var.tags)
}

# Necesario para anclar las políticas SQS al account_id propio (evita wildcard)
data "aws_caller_identity" "current" {}

# ─────────────────────────────────────────────────────────────────────────────
# SNS TOPICS
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_sns_topic" "reservas" {
  name              = "${local.name_prefix}-topic-reservas"
  kms_master_key_id = var.kms_key_arn

  tags = { Name = "${local.name_prefix}-topic-reservas" }
}

resource "aws_sns_topic" "pagos" {
  name              = "${local.name_prefix}-topic-pagos"
  kms_master_key_id = var.kms_key_arn

  tags = { Name = "${local.name_prefix}-topic-pagos" }
}

resource "aws_sns_topic" "auditoria" {
  name              = "${local.name_prefix}-topic-auditoria"
  kms_master_key_id = var.kms_key_arn

  tags = { Name = "${local.name_prefix}-topic-auditoria" }
}

# ─────────────────────────────────────────────────────────────────────────────
# DEAD LETTER QUEUES (DLQ)
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_sqs_queue" "reservas_notificaciones_dlq" {
  name                      = "${local.name_prefix}-reservas-notificaciones-dlq"
  kms_master_key_id         = var.kms_key_arn
  message_retention_seconds = 1209600

  tags = {
    Name = "${local.name_prefix}-reservas-notificaciones-dlq"
    Flow = "reservas-notificaciones"
  }
}

resource "aws_sqs_queue" "pagos_notificaciones_dlq" {
  name                      = "${local.name_prefix}-pagos-notificaciones-dlq"
  kms_master_key_id         = var.kms_key_arn
  message_retention_seconds = 1209600

  tags = {
    Name = "${local.name_prefix}-pagos-notificaciones-dlq"
    Flow = "pagos-notificaciones"
  }
}

resource "aws_sqs_queue" "reservas_pagos_dlq" {
  name                      = "${local.name_prefix}-reservas-pagos-dlq"
  kms_master_key_id         = var.kms_key_arn
  message_retention_seconds = 1209600

  tags = {
    Name = "${local.name_prefix}-reservas-pagos-dlq"
    Flow = "reservas-pagos"
  }
}

resource "aws_sqs_queue" "auditoria_dlq" {
  name                      = "${local.name_prefix}-auditoria-dlq"
  kms_master_key_id         = var.kms_key_arn
  message_retention_seconds = 1209600

  tags = {
    Name = "${local.name_prefix}-auditoria-dlq"
    Flow = "auditoria"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# SQS QUEUES PRINCIPALES
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_sqs_queue" "reservas_notificaciones" {
  name                       = "${local.name_prefix}-reservas-notificaciones"
  kms_master_key_id          = var.kms_key_arn
  visibility_timeout_seconds = 30
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 20

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.reservas_notificaciones_dlq.arn
    maxReceiveCount     = 3
  })

  tags = {
    Name     = "${local.name_prefix}-reservas-notificaciones"
    Flow     = "reservas-notificaciones"
    Producer = "ms-reservas"
    Consumer = "ms-notificaciones"
  }
}

resource "aws_sqs_queue" "pagos_notificaciones" {
  name                       = "${local.name_prefix}-pagos-notificaciones"
  kms_master_key_id          = var.kms_key_arn
  visibility_timeout_seconds = 30
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 20

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.pagos_notificaciones_dlq.arn
    maxReceiveCount     = 3
  })

  tags = {
    Name     = "${local.name_prefix}-pagos-notificaciones"
    Flow     = "pagos-notificaciones"
    Producer = "ms-pagos"
    Consumer = "ms-notificaciones"
  }
}

resource "aws_sqs_queue" "reservas_pagos" {
  name                       = "${local.name_prefix}-reservas-pagos"
  kms_master_key_id          = var.kms_key_arn
  visibility_timeout_seconds = 60
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 20

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.reservas_pagos_dlq.arn
    maxReceiveCount     = 3
  })

  tags = {
    Name     = "${local.name_prefix}-reservas-pagos"
    Flow     = "reservas-pagos"
    Producer = "ms-reservas"
    Consumer = "ms-pagos"
  }
}

resource "aws_sqs_queue" "auditoria" {
  name                       = "${local.name_prefix}-auditoria"
  kms_master_key_id          = var.kms_key_arn
  visibility_timeout_seconds = 30
  message_retention_seconds  = 1209600
  receive_wait_time_seconds  = 20

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.auditoria_dlq.arn
    maxReceiveCount     = 3
  })

  tags = {
    Name     = "${local.name_prefix}-auditoria"
    Flow     = "auditoria"
    Consumer = "ms-auditoria"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# SNS → SQS SUBSCRIPTIONS
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_sns_topic_subscription" "reservas_to_notificaciones" {
  topic_arn            = aws_sns_topic.reservas.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.reservas_notificaciones.arn
  raw_message_delivery = true
}

resource "aws_sns_topic_subscription" "pagos_to_notificaciones" {
  topic_arn            = aws_sns_topic.pagos.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.pagos_notificaciones.arn
  raw_message_delivery = true
}

resource "aws_sns_topic_subscription" "reservas_to_pagos" {
  topic_arn            = aws_sns_topic.reservas.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.reservas_pagos.arn
  raw_message_delivery = true
}

resource "aws_sns_topic_subscription" "reservas_to_auditoria" {
  topic_arn            = aws_sns_topic.reservas.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.auditoria.arn
  raw_message_delivery = true
}

resource "aws_sns_topic_subscription" "pagos_to_auditoria" {
  topic_arn            = aws_sns_topic.pagos.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.auditoria.arn
  raw_message_delivery = true
}

resource "aws_sns_topic_subscription" "auditoria_to_auditoria" {
  topic_arn            = aws_sns_topic.auditoria.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.auditoria.arn
  raw_message_delivery = true
}

# ─────────────────────────────────────────────────────────────────────────────
# SQS QUEUE POLICIES
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_sqs_queue_policy" "reservas_notificaciones" {
  queue_url = aws_sqs_queue.reservas_notificaciones.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowSNSReservas"
      Effect    = "Allow"
      Principal = { Service = "sns.amazonaws.com" }
      Action    = "sqs:SendMessage"
      Resource  = aws_sqs_queue.reservas_notificaciones.arn
      Condition = {
        ArnEquals = { "aws:SourceArn" = aws_sns_topic.reservas.arn }
      }
    }]
  })
}

resource "aws_sqs_queue_policy" "pagos_notificaciones" {
  queue_url = aws_sqs_queue.pagos_notificaciones.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowSNSPagos"
      Effect    = "Allow"
      Principal = { Service = "sns.amazonaws.com" }
      Action    = "sqs:SendMessage"
      Resource  = aws_sqs_queue.pagos_notificaciones.arn
      Condition = {
        ArnEquals = { "aws:SourceArn" = aws_sns_topic.pagos.arn }
      }
    }]
  })
}

resource "aws_sqs_queue_policy" "reservas_pagos" {
  queue_url = aws_sqs_queue.reservas_pagos.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowSNSReservas"
      Effect    = "Allow"
      Principal = { Service = "sns.amazonaws.com" }
      Action    = "sqs:SendMessage"
      Resource  = aws_sqs_queue.reservas_pagos.arn
      Condition = {
        ArnEquals = { "aws:SourceArn" = aws_sns_topic.reservas.arn }
      }
    }]
  })
}

resource "aws_sqs_queue_policy" "auditoria" {
  queue_url = aws_sqs_queue.auditoria.id

  # CKV_AWS_168: Usar ARNs explícitos de cada topic — sin wildcard en account_id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowSNSTopicsAuditoria"
      Effect    = "Allow"
      Principal = { Service = "sns.amazonaws.com" }
      Action    = "sqs:SendMessage"
      Resource  = aws_sqs_queue.auditoria.arn
      Condition = {
        ArnEquals = {
          "aws:SourceArn" = [
            aws_sns_topic.reservas.arn,
            aws_sns_topic.pagos.arn,
            aws_sns_topic.auditoria.arn
          ]
        }
      }
    }]
  })
}