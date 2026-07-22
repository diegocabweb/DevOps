# Módulo 04: Terraform Remote Backend (S3 + DynamoDB)

## Objetivos
- Implementar la gestión remota del estado de Terraform mediante un Bucket S3 en Floci/AWS.
- Habilitar el bloqueo de estado (State Locking) a través de una tabla DynamoDB.
- Migrar de forma segura el archivo terraform.tfstate desde el almacenamiento local al entorno remoto.

## Arquitectura del Backend
- **S3 Bucket**: mlops-tf-state-floci (Almacenamiento de estado centralizado con versionado activo).
- **DynamoDB Table**: mlops-tf-locks (Manejo de concurrencia y bloqueo de estado).
- **Ruta del Estado**: 04-remote-backend/terraform.tfstate

## Comandos Utilizados

1. Inicialización y creación de recursos del backend:
   
   terraform init
   terraform apply

2. Migración del estado al backend remoto:
   
   terraform init (Ingresando 'yes' para migrar el estado local)