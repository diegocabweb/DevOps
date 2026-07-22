# 1. Bucket S3 para almacenar el archivo terraform.tfstate de forma remota
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "mlops-tf-state-floci"
  force_destroy = true # Permite destruir el bucket en pruebas aunque tenga objetos

  tags = {
    Name        = "Terraform State Store"
    Environment = var.environment
  }
}

# 2. Habilitar versionado en el bucket (Buena práctica para recuperar estados anteriores)
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 3. Tabla DynamoDB para el bloqueo de estado (State Locking)
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "mlops-tf-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform State Lock Table"
    Environment = var.environment
  }
}