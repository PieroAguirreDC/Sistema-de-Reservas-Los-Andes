#!/usr/bin/env bash
# =============================================================================
# bootstrap.sh — Crea los recursos previos al primer terraform init
# Ejecutar UNA SOLA VEZ antes de inicializar el backend remoto
# Uso: bash bootstrap.sh [dev|prod]
# =============================================================================
set -euo pipefail

ENVIRONMENT="${1:-dev}"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION="us-east-1"
BUCKET_NAME="reservas-tfstate-${ACCOUNT_ID}"
TABLE_NAME="reservas-terraform-locks"

echo "🚀 Bootstrap del backend Terraform para cuenta ${ACCOUNT_ID} — entorno: ${ENVIRONMENT}"
echo ""

# ─── 1. Bucket S3 para estado remoto ─────────────────────────────────────────
echo "📦 Creando bucket S3: ${BUCKET_NAME}"
if aws s3api head-bucket --bucket "${BUCKET_NAME}" 2>/dev/null; then
  echo "   ✅ El bucket ya existe, omitiendo creación."
else
  aws s3api create-bucket \
    --bucket "${BUCKET_NAME}" \
    --region "${REGION}"

  # Habilitar versionado (punto de recuperación del estado)
  aws s3api put-bucket-versioning \
    --bucket "${BUCKET_NAME}" \
    --versioning-configuration Status=Enabled

  # Cifrado AES-256 en reposo
  aws s3api put-bucket-encryption \
    --bucket "${BUCKET_NAME}" \
    --server-side-encryption-configuration '{
      "Rules": [{
        "ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"},
        "BucketKeyEnabled": true
      }]
    }'

  # Bloquear acceso público
  aws s3api put-public-access-block \
    --bucket "${BUCKET_NAME}" \
    --public-access-block-configuration '{
      "BlockPublicAcls": true,
      "IgnorePublicAcls": true,
      "BlockPublicPolicy": true,
      "RestrictPublicBuckets": true
    }'

  echo "   ✅ Bucket creado y configurado."
fi

# ─── 2. Tabla DynamoDB para bloqueo de concurrencia ──────────────────────────
echo "🔒 Creando tabla DynamoDB: ${TABLE_NAME}"
if aws dynamodb describe-table --table-name "${TABLE_NAME}" --region "${REGION}" 2>/dev/null; then
  echo "   ✅ La tabla ya existe, omitiendo creación."
else
  aws dynamodb create-table \
    --table-name "${TABLE_NAME}" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "${REGION}"

  aws dynamodb wait table-exists --table-name "${TABLE_NAME}" --region "${REGION}"
  echo "   ✅ Tabla DynamoDB creada."
fi

echo ""
echo "✅ Bootstrap completado. Ahora puedes ejecutar:"
echo ""
echo "   cd Sistema-de-Reservas/iac"
echo "   export TF_VAR_db_master_password='tu-password-segura-aqui'"
echo "   export TF_VAR_redis_auth_token='tu-token-redis-minimo-16c'"
echo "   terraform init"
echo "   terraform plan -var-file=terraform.tfvars"
echo ""
