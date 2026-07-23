terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Fijamos la versión 5.x para evitar quiebres con v6.0
    }
  }

  backend "s3" {
    bucket       = "mlops-tf-state-floci"
    key          = "05-workspaces/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}

provider "aws" {
  region = "us-east-1"
}