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
# ... mantén aquí arriba tu bloque "terraform" y "provider" de ayer ...

# Definición de tu primer bucket de S3 local usando variables
resource "aws_s3_bucket" "mi_bucket_local" {
  bucket = var.nombre_bucket  # <-- Aquí llamamos a la variable

  tags = {
    Entorno   = var.entorno   # <-- Aquí llamamos a la otra variable
    CreadoPor = "Terraform"
  }
}