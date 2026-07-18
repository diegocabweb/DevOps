output "url_servidor" {
  description = "Dirección IP para acceder al servidor web"
  value       = "http://${aws_instance.servidor_web.public_ip}"
}