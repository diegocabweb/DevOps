variable "aws_region" {
  type        = string
  description = "Región de AWS simulada"
  default     = "us-east-1"
}

variable "floci_endpoint" {
  type        = string
  description = "Endpoint del emulador local Floci"
  default     = "http://localhost:4566"
}

variable "environment" {
  type        = string
  description = "Entorno de despliegue (dev, qa, prod)"
  default     = "dev"
}

variable "instance_type" {
  type        = string
  description = "Tipo de instancia EC2"
  default     = "t2.micro"
}

variable "http_port" {
  type        = number
  description = "Puerto de entrada para el servidor web"
  default     = 80
}