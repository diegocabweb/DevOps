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
    ec2 = "http://localhost:4566"
  }
}

# 1. Configuración del Firewall (Security Group)
resource "aws_security_group" "firewall_web" {
  name        = "permitir_trafico_web"
  description = "Permite acceso SSH y HTTP local"

  # Regla de entrada para SSH (Tus bases de Linux)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Regla de entrada para HTTP (Nginx)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Regla de salida (Permitir que la máquina descargue paquetes)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. Despliegue de la Instancia Linux
resource "aws_instance" "servidor_web" {
  ami           = "ami-12345678" # En Floci cualquier ID de AMI suele funcionar
  instance_type = "t2.micro"
  
  # Conectamos la máquina con el firewall que creamos arriba
  vpc_security_group_ids = [aws_security_group.firewall_web.id]

  # SCRIPT BASH (User Data): Automatización Middleware pura al arrancar
  # SCRIPT AJUSTADO PARA AMAZON LINUX 2023
    user_data = <<-EOF
                #!/bin/bash
                dnf update -y
                dnf install nginx -y
                echo "<h1>Hola Mundo desde mi Linux automatizado con Terraform</h1>" > /usr/share/nginx/html/index.html
                systemctl start nginx
                systemctl enable nginx
                EOF

  tags = {
    Name      = "servidor-nginx-local"
    Ambiente  = "Laboratorio"
  }
}