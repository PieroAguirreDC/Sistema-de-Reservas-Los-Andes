# SNS TOPICS
output "sns_topic_reservas_arn" {
  description = "ARN del topic SNS de reservas (producer: ms-reservas)"
  value       = aws_sns_topic.reservas.arn
}

output "sns_topic_pagos_arn" {
  description = "ARN del topic SNS de pagos (producer: ms-pagos)"
  value       = aws_sns_topic.pagos.arn
}

output "sns_topic_auditoria_arn" {
  description = "ARN del topic SNS de auditoría"
  value       = aws_sns_topic.auditoria.arn
}

# SQS QUEUES
output "sqs_reservas_notificaciones_url" {
  description = "URL de la cola reservas→notificaciones (consumer: ms-notificaciones)"
  value       = aws_sqs_queue.reservas_notificaciones.id
}

output "sqs_reservas_notificaciones_arn" {
  description = "ARN de la cola reservas→notificaciones"
  value       = aws_sqs_queue.reservas_notificaciones.arn
}

output "sqs_pagos_notificaciones_url" {
  description = "URL de la cola pagos→notificaciones (consumer: ms-notificaciones)"
  value       = aws_sqs_queue.pagos_notificaciones.id
}

output "sqs_pagos_notificaciones_arn" {
  description = "ARN de la cola pagos→notificaciones"
  value       = aws_sqs_queue.pagos_notificaciones.arn
}

output "sqs_reservas_pagos_url" {
  description = "URL de la cola reservas→pagos (consumer: ms-pagos)"
  value       = aws_sqs_queue.reservas_pagos.id
}

output "sqs_reservas_pagos_arn" {
  description = "ARN de la cola reservas→pagos"
  value       = aws_sqs_queue.reservas_pagos.arn
}

output "sqs_auditoria_url" {
  description = "URL de la cola auditoría (consumer: ms-auditoria)"
  value       = aws_sqs_queue.auditoria.id
}

output "sqs_auditoria_arn" {
  description = "ARN de la cola auditoría"
  value       = aws_sqs_queue.auditoria.arn
}

# DLQs
output "dlq_reservas_notificaciones_arn" {
  description = "ARN de la DLQ reservas→notificaciones"
  value       = aws_sqs_queue.reservas_notificaciones_dlq.arn
}

output "dlq_pagos_notificaciones_arn" {
  description = "ARN de la DLQ pagos→notificaciones"
  value       = aws_sqs_queue.pagos_notificaciones_dlq.arn
}

output "dlq_reservas_pagos_arn" {
  description = "ARN de la DLQ reservas→pagos"
  value       = aws_sqs_queue.reservas_pagos_dlq.arn
}

output "dlq_auditoria_arn" {
  description = "ARN de la DLQ auditoría"
  value       = aws_sqs_queue.auditoria_dlq.arn
}

output "sqs_reservas_habitaciones_url" {
  description = "URL de la cola reservas→habitaciones"
  value       = aws_sqs_queue.reservas_habitaciones.id
}

output "sqs_reservas_habitaciones_arn" {
  description = "ARN de la cola reservas→habitaciones"
  value       = aws_sqs_queue.reservas_habitaciones.arn
}