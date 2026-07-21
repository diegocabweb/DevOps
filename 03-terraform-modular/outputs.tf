output "instance_id" {
  value       = aws_instance.web_server.id
  description = "ID de la instancia EC2 creada"
}

output "security_group_id" {
  value       = aws_security_group.web_sg.id
  description = "ID del Security Group asociado"
}

output "environment_tag" {
  value       = aws_instance.web_server.tags["Environment"]
  description = "Entorno en el que se desplegó la infraestructura"
}