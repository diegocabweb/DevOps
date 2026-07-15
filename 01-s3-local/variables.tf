variable "nombre_bucket" {
  description = "El nombre único que tendrá nuestro bucket de S3 local"
  type        = string
  default     = "mi-bucket-parametrizado-con-variables_2"
}

variable "entorno" {
  description = "Ambiente de despliegue (Local, Dev, Prod)"
  type        = string
  default     = "Local"
}