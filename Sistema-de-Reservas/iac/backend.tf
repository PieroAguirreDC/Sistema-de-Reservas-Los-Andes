terraform {
  backend "s3" {
    # ─── IMPORTANTE: Antes de terraform init, crear estos recursos manualmente ───
    # aws s3api create-bucket --bucket reservas-tfstate-734101502785 --region us-east-1
    # aws s3api put-bucket-versioning --bucket reservas-tfstate-734101502785 --versioning-configuration Status=Enabled
    # aws s3api put-bucket-encryption --bucket reservas-tfstate-734101502785 --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
    # aws dynamodb create-table --table-name reservas-terraform-locks --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --billing-mode PAY_PER_REQUEST --region us-east-1
    bucket         = "reservas-tfstate-734101502785"
    key            = "reservas/dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "reservas-terraform-locks"
  }
}
