output "instance_id" {
  description = "ID de la instancia EC2"
  value       = aws_instance.web_server.id
}

output "instance_public_ip" {
  description = "IP pública de la instancia"
  value       = aws_instance.web_server.public_ip
}

output "environment_tag" {
  description = "Entorno activo"
  value       = terraform.workspace
}

output "security_group_id" {
  description = "ID del Security Group"
  value       = aws_security_group.web_sg.id
}