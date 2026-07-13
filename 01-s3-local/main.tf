terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "mock_key"       # El emulador acepta cualquier texto
  secret_key                  = "mock_secret"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  # Redirigimos el servicio S3 a tu localhost (Floci)
  endpoints {
    s3 = "http://localhost:4566"
  }
}

# Definición de tu primer bucket de S3 local
resource "aws_s3_bucket" "mi_bucket_local" {
  bucket = "mi-primer-bucket-automatizado"

  tags = {
    Entorno   = "Local"
    CreadoPor = "Terraform"
  }
}