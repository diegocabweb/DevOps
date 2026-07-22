terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Configuración del Backend Remoto
  backend "s3" {
    bucket         = "mlops-tf-state-floci"
    key            = "04-remote-backend/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "mlops-tf-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}