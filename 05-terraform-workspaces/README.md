# Módulo 05: Terraform Workspaces (`dev` / `prod`)

## 📌 Descripción General
Este módulo documenta la implementación de entornos aislados de infraestructura en AWS (`dev` y `prod`) utilizando **Terraform Workspaces** sobre una misma base de código. Se abordan la configuración de estado remoto en Amazon S3, la actualización de parámetros del proveedor de AWS y la gestión del ciclo de vida completo (creación, validación y destrucción) de los recursos.

---

## 🎯 Objetivos de la Actividad
1. **Configurar el Backend Remoto**: Almacenar el archivo de estado (`terraform.tfstate`) en Amazon S3 utilizando la nueva especificación de bloqueo con `use_lockfile = true` (proveedor AWS v5.x/v6.x).
2. **Implementar Workspaces**: Crear y gestionar espacios de trabajo independientes (`dev` y `prod`) para reutilizar la misma plantilla de código con parámetros dinámicos.
3. **Parametrización Dinámica**: Asignar nombres, tags y tipos de instancia según el espacio de trabajo activo mediante `terraform.workspace`.
4. **Ciclo de Vida Completo**: Ejecutar el aprovisionamiento y posterior destrucción controlada de los recursos sin afectar la infraestructura de backend.

---

## 🏗️ Arquitectura e Infraestructura

La plantilla despliega la siguiente infraestructura básica en la VPC por defecto de AWS:

* **Seguridad**: Grupo de seguridad (`aws_security_group`) con acceso HTTP (puerto 80) e inyección del tag de entorno.
* **Cómputo**: Instancia EC2 (`aws_instance`) basada en Amazon Linux 2023 (`data "aws_ami"`), provisionada en la primera Subnet disponible (`data "aws_subnets"`).
* **Condicionales de Entorno**:
  * **Instancia `dev`**: Tipo `t3.micro`.
  * **Instancia `prod`**: Tipo `t3.small`.

---

## 📂 Estructura de Archivos

```text
05-terraform-workspaces/
├── providers.tf     # Configuración del proveedor AWS (~> 5.0) y backend remotos en S3
├── main.tf          # Recursos nativos (EC2, SG, Data Sources) y lógica de Workspaces
└── outputs.tf       # Salidas de configuración (IDs de instancia, IP pública y Workspace)
Código Clave de Configuración
providers.tf
Terraform
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
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
main.tf
Terraform
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "web_sg" {
  name        = "web-sg-${terraform.workspace}"
  description = "Security group for ${terraform.workspace} environment"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "web-sg-${terraform.workspace}"
    Environment = terraform.workspace
  }
}

resource "aws_instance" "web_server" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = terraform.workspace == "prod" ? "t3.small" : "t3.micro"
  subnet_id     = data.aws_subnets.default.ids[0]

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name        = "web-server-${terraform.workspace}"
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
  }
}
🛠️ Comandos Ejecutados y Flujo de Trabajo
1. Inicialización del Proyecto
Bash
# Limpieza de caché local previa por incompatibilidad de versiones
rm -rf .terraform .terraform.lock.hcl

# Inicialización y reconfiguración del backend remoto
terraform init -reconfigure
2. Gestión de Workspaces y Aprovisionamiento
Bash
# Crear y/o seleccionar workspace dev
terraform workspace select dev

# Planificar y aplicar infraestructura en desarrollo
terraform plan
terraform apply -auto-approve

# Cambiar a producción y desplegar
terraform workspace select prod
terraform plan
terraform apply -auto-approve
3. Destrucción de Entornos (Limpieza de Costos)
Bash
# Destrucción del entorno de producción
terraform workspace select prod
terraform destroy -auto-approve

# Destrucción del entorno de desarrollo
terraform workspace select dev
terraform destroy -auto-approve

# Retorno al workspace default
terraform workspace select default
💡 Lecciones Aprendidas y Solución de Problemas
Deprecación de dynamodb_table en Backend S3:

En las versiones modernas del proveedor de AWS, el parámetro dynamodb_table para el bloqueo del archivo de estado fue sustituido por use_lockfile = true.

Separación de Backend vs. Aplicación:

Los recursos base de estado (Bucket S3 y DynamoDB) no deben incluirse en los archivos .tf de los módulos de aplicación para evitar errores de colisión (BucketAlreadyExists).

Referencias entre Recurso Nativo vs. Módulo:

Al hacer referencia a atributos en outputs.tf, los recursos nativos usan la sintaxis aws_instance.nombre.id, mientras que los módulos usan module.nombre_modulo.output. Se optó por recursos nativos para mantener la portabilidad directa.