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
    Module      = "ecs-fargate"
  }, var.tags)
}

resource "aws_iam_role" "ecs_execution" {
  name = "${local.name_prefix}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ─── LOG GROUPS POR MICROSERVICIO ─────────────────────────────────────────────

resource "aws_cloudwatch_log_group" "usuarios" {
  name              = "/ecs/${local.name_prefix}/usuarios"
  retention_in_days = 365
  kms_key_id        = var.kms_key_arn
}

resource "aws_cloudwatch_log_group" "habitaciones" {
  name              = "/ecs/${local.name_prefix}/habitaciones"
  retention_in_days = 365
  kms_key_id        = var.kms_key_arn
}

resource "aws_cloudwatch_log_group" "reservas" {
  name              = "/ecs/${local.name_prefix}/reservas"
  retention_in_days = 365
  kms_key_id        = var.kms_key_arn
}

resource "aws_cloudwatch_log_group" "pagos" {
  name              = "/ecs/${local.name_prefix}/pagos"
  retention_in_days = 365
  kms_key_id        = var.kms_key_arn
}

resource "aws_cloudwatch_log_group" "notificaciones" {
  name              = "/ecs/${local.name_prefix}/notificaciones"
  retention_in_days = 365
  kms_key_id        = var.kms_key_arn
}

resource "aws_cloudwatch_log_group" "web" {
  name              = "/ecs/${local.name_prefix}/web"
  retention_in_days = 365
  kms_key_id        = var.kms_key_arn
}

resource "aws_ecs_cluster" "main" {
  name = "${local.name_prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# TASK ROLE — permisos en tiempo de ejecución del backend (S3, SNS/SQS)
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_iam_role" "ecs_task" {
  name = "${local.name_prefix}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_s3_uploads" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = var.s3_uploads_policy_arn
}

data "aws_iam_policy_document" "ecs_task_messaging" {
  statement {
    sid     = "PublishReservasYPagos"
    effect  = "Allow"
    actions = ["sns:Publish"]
    resources = [
      var.sns_topic_reservas_arn,
      var.sns_topic_pagos_arn,
    ]
  }

  statement {
    sid     = "ConsumirColasNotificaciones"
    effect  = "Allow"
    actions = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
    resources = [
      var.sqs_reservas_notificaciones_arn,
      var.sqs_pagos_notificaciones_arn,
      var.sqs_reservas_pagos_arn,
    ]
  }
}

resource "aws_iam_role_policy" "ecs_task_messaging" {
  name   = "${local.name_prefix}-ecs-task-messaging"
  role   = aws_iam_role.ecs_task.id
  policy = data.aws_iam_policy_document.ecs_task_messaging.json
}

# Permiso para que el EXECUTION role pueda leer el secret de RDS al arrancar
# el contenedor (inyección vía "secrets" en el container_definitions)
data "aws_iam_policy_document" "ecs_execution_secrets" {
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [var.secret_rds_arn]
  }

  # KMS requerido para:
  # 1) Descifrar el secret de Secrets Manager (cifrado con KMS)
  # 2) Escribir en el CloudWatch log group cifrado con KMS
  statement {
    effect  = "Allow"
    actions = ["kms:Decrypt", "kms:GenerateDataKey"]
    resources = [var.kms_key_arn]
  }
}

resource "aws_iam_role_policy" "ecs_execution_secrets" {
  name   = "${local.name_prefix}-ecs-execution-secrets"
  role   = aws_iam_role.ecs_execution.name
  policy = data.aws_iam_policy_document.ecs_execution_secrets.json
}

# ─────────────────────────────────────────────────────────────────────────────
# ENVIRONMENT VARIABLES COMUNES PARA MICROSERVICIOS
# ─────────────────────────────────────────────────────────────────────────────
locals {
  common_env = [
    { name = "NODE_ENV", value = var.environment },
    { name = "PORT", value = "3000" },
    { name = "DB_HOST", value = var.rds_proxy_endpoint },
    { name = "DB_PORT", value = tostring(var.aurora_port) },
    { name = "DB_NAME", value = var.aurora_database_name },
    { name = "DB_SSL", value = "true" },
    { name = "REDIS_HOST", value = var.redis_primary_endpoint },
    { name = "REDIS_PORT", value = tostring(var.redis_port) },
    { name = "AWS_REGION", value = var.aws_region },
    { name = "S3_BUCKET_PUBLIC", value = var.s3_bucket_public },
    { name = "S3_BUCKET_PRIVATE", value = var.s3_bucket_private },
    { name = "SNS_TOPIC_RESERVAS_ARN", value = var.sns_topic_reservas_arn },
    { name = "SNS_TOPIC_PAGOS_ARN", value = var.sns_topic_pagos_arn },
    { name = "SQS_RESERVAS_NOTIFICACIONES_URL", value = var.sqs_reservas_notificaciones_url },
    { name = "SQS_PAGOS_NOTIFICACIONES_URL", value = var.sqs_pagos_notificaciones_url },
    { name = "SQS_RESERVAS_PAGOS_URL", value = var.sqs_reservas_pagos_url }
  ]

  common_secrets = [
    { name = "DB_USERNAME", valueFrom = "${var.secret_rds_arn}:username::" },
    { name = "DB_PASSWORD", valueFrom = "${var.secret_rds_arn}:password::" }
  ]
}

# ─────────────────────────────────────────────────────────────────────────────
# TASK DEFINITIONS
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_ecs_task_definition" "usuarios" {
  family                   = "${local.name_prefix}-usuarios"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.api_cpu
  memory                   = var.api_memory
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([{
    name                   = "usuarios"
    image                  = var.usuarios_image_uri
    essential              = true
    readonlyRootFilesystem = true
    portMappings = [{
      containerPort = 3000
      protocol      = "tcp"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.usuarios.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "usuarios"
      }
    }
    environment = concat(local.common_env, [
      { name = "SERVICE_NAME", value = "usuarios" }
    ])
    secrets = local.common_secrets
  }])
}

resource "aws_ecs_task_definition" "habitaciones" {
  family                   = "${local.name_prefix}-habitaciones"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.api_cpu
  memory                   = var.api_memory
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([{
    name                   = "habitaciones"
    image                  = var.habitaciones_image_uri
    essential              = true
    readonlyRootFilesystem = true
    portMappings = [{
      containerPort = 3000
      protocol      = "tcp"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.habitaciones.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "habitaciones"
      }
    }
    environment = concat(local.common_env, [
      { name = "SERVICE_NAME", value = "habitaciones" }
    ])
    secrets = local.common_secrets
  }])
}

resource "aws_ecs_task_definition" "reservas" {
  family                   = "${local.name_prefix}-reservas"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.api_cpu
  memory                   = var.api_memory
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([{
    name                   = "reservas"
    image                  = var.reservas_image_uri
    essential              = true
    readonlyRootFilesystem = true
    portMappings = [{
      containerPort = 3000
      protocol      = "tcp"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.reservas.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "reservas"
      }
    }
    environment = concat(local.common_env, [
      { name = "SERVICE_NAME", value = "reservas" }
    ])
    secrets = local.common_secrets
  }])
}

resource "aws_ecs_task_definition" "pagos" {
  family                   = "${local.name_prefix}-pagos"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.api_cpu
  memory                   = var.api_memory
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([{
    name                   = "pagos"
    image                  = var.pagos_image_uri
    essential              = true
    readonlyRootFilesystem = true
    portMappings = [{
      containerPort = 3000
      protocol      = "tcp"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.pagos.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "pagos"
      }
    }
    environment = concat(local.common_env, [
      { name = "SERVICE_NAME", value = "pagos" }
    ])
    secrets = local.common_secrets
  }])
}

resource "aws_ecs_task_definition" "notificaciones" {
  family                   = "${local.name_prefix}-notificaciones"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.api_cpu
  memory                   = var.api_memory
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([{
    name                   = "notificaciones"
    image                  = var.notificaciones_image_uri
    essential              = true
    readonlyRootFilesystem = true
    portMappings = [{
      containerPort = 3000
      protocol      = "tcp"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.notificaciones.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "notificaciones"
      }
    }
    environment = concat(local.common_env, [
      { name = "SERVICE_NAME", value = "notificaciones" }
    ])
    secrets = local.common_secrets
  }])
}

resource "aws_ecs_task_definition" "web" {
  family                   = "${local.name_prefix}-web"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.web_cpu
  memory                   = var.web_memory
  execution_role_arn       = aws_iam_role.ecs_execution.arn

  container_definitions = jsonencode([{
    name                   = "web"
    image                  = var.web_image_uri
    essential              = true
    readonlyRootFilesystem = true
    portMappings = [{
      containerPort = 3001
      protocol      = "tcp"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.web.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "web"
      }
    }
    environment = [
      { name = "NODE_ENV", value = var.environment },
      { name = "PORT", value = "3001" }
    ]
  }])
}

# ─────────────────────────────────────────────────────────────────────────────
# ECS SERVICES
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_ecs_service" "usuarios" {
  name            = "${local.name_prefix}-usuarios-svc"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.usuarios.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.sg_ecs_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.usuarios_target_group_arn
    container_name   = "usuarios"
    container_port   = 3000
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}

resource "aws_ecs_service" "habitaciones" {
  name            = "${local.name_prefix}-habitaciones-svc"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.habitaciones.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.sg_ecs_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.habitaciones_target_group_arn
    container_name   = "habitaciones"
    container_port   = 3000
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}

resource "aws_ecs_service" "reservas" {
  name            = "${local.name_prefix}-reservas-svc"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.reservas.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.sg_ecs_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.reservas_target_group_arn
    container_name   = "reservas"
    container_port   = 3000
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}

resource "aws_ecs_service" "pagos" {
  name            = "${local.name_prefix}-pagos-svc"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.pagos.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.sg_ecs_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.pagos_target_group_arn
    container_name   = "pagos"
    container_port   = 3000
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}

resource "aws_ecs_service" "notificaciones" {
  name            = "${local.name_prefix}-notificaciones-svc"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.notificaciones.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.sg_ecs_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.notificaciones_target_group_arn
    container_name   = "notificaciones"
    container_port   = 3000
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}

resource "aws_ecs_service" "web" {
  name            = "${local.name_prefix}-web-svc"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.web.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.sg_ecs_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.web_target_group_arn
    container_name   = "web"
    container_port   = 3001
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}