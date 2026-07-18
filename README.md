Iniciando un nuevo proceso de aprendizaje utilizando IA

# 1. Alistamiento

Instalar Homebrew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Instalar Terraform
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

Instalar vscode
```bash
brew install --cask visual-studio-code
```

Se instala docker desktop en la interfaz gráfica

Instalar AWS S3
```bash
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
which aws
aws --version
```

Instalar floci
```bash
brew install floci-io/floci/floci
floci start
eval $(floci env)
#exports AWS_ENDPOINT_URL, AWS_ACCESS_KEY_ID,
#AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION
```

Create a bucket
```bash
aws s3 mb s3://my-bucket
```

Write a file and upload it
```bash
echo "Why pay for S3 when floci is free? 🎉" > hello-floci.txt
aws s3 cp hello-floci.txt \
  s3://my-bucket/hello-floci.txt
```

Download it back and read it
```bash
aws s3 cp s3://my-bucket/hello-floci.txt \
  hello-back.txt
cat hello-back.txt
```

Check status
```bash
floci status
```

View logs
```bash
floci logs --follow
```

Stop the emulator
```bash
floci stop
```

Run health diagnostics
```bash
floci doctor
```

State survives container restarts
```bash
floci start --persist ./data
```

Save and restore state
```bash
floci snapshot save my-snapshot
floci snapshot restore my-snapshot
```

# 2. Inciando con Terraform
Iniciar docker desktop y verificar que docker está activo:
```bash
docker ps
```

Iniciar floci
```bash
floci start
```

Crear el directorio
```bash
cd Documents/Proyectos_Code/DevOps/
mkdir 01-s3-local
cd 01-s3-local
```bash

Se crea el archivo main.tf con el siguiente contenido, teniendo en cuenta que la infra se va aplicar en AWS - Floci

```terraform
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
    s3 = "http://localhost:4566"
  }
}

# Definición de tu primer bucket de S3 local
resource "aws_s3_bucket" "mi_bucket_local" {
  bucket = "mi-primer-bucket-automatizado"

  tags = {
    Entorno   = "Local"
    CreadoPor = "Terraform"
  }
}
```

Luego inicializa el proyecto Terraform:
```bash
terraform init
```

Validar el plan antes de aplicar:
```bash
terraform plan
```

Aplicar el plan en Terraform, en este caso, crear un bucket S3
```bash
terraform apply
```

Verificar que se creo de manera correcta:
```bash
aws --endpoint-url=http://localhost:4566 s3 ls
```

También con:
```bash
aws s3 ls
```
## NOTA
Antes de hacer un commit a Github, para evitar este error se debe hacer lo siguiente:
```bash
remote: error: File 01-s3-local/.terraform/providers/registry.terraform.io/hashicorp/aws/5.100.0/darwin_arm64/terraform-provider-aws_v5.100.0_x5 is 648.39 MB; this exceeds GitHub's file size limit of 100.00 MB
```

En la raiz del proyecto Git se debe crear un archivo .gitignore al menos con el siguiente contenido para que no suba a GitHub
Ya sean archivos grandes o de resgo

```bash
# Terraform
**/.terraform/*
*.tfstate
*.tfstate.*
crash.log

# Variables sensibles
*.tfvars
*.tfvars.json

# Planes de Terraform
*.tfplan

# Lock file (opcional)
# .terraform.lock.hcl

```

# 3. Variables y Outputs con Terraform
Parametrizar la infra y no tener información "quemada en el código" harcoded

## variables.tf
Parametros de entrada, como nombre del bucket o region

## outputs.tf
Datos de resultado en pantalla como ARN o nombre de dominio del bucket

## Contenido
variables.tf
```bash
variable "nombre_bucket" {
  description = "El nombre único que tendrá nuestro bucket de S3 local"
  type        = string
  default     = "mi-bucket-parametrizado-con-variables"
}

variable "entorno" {
  description = "Ambiente de despliegue (Local, Dev, Prod)"
  type        = string
  default     = "Local"
}
```

outputs.tf
```bash
output "bucket_arn" {
  description = "El ARN (Amazon Resource Name) del bucket creado"
  value       = aws_s3_bucket.mi_bucket_local.arn
}

output "bucket_domain_name" {
  description = "El nombre de dominio del bucket de S3"
  value       = aws_s3_bucket.mi_bucket_local.bucket_domain_name
}
```

Ahora integrarlo en el archivo main.tf
```bash
# ... mantén aquí arriba tu bloque "terraform" y "provider" de ayer ...

# Definición de tu primer bucket de S3 local usando variables
resource "aws_s3_bucket" "mi_bucket_local" {
  bucket = var.nombre_bucket  # <-- Aquí llamamos a la variable

  tags = {
    Entorno   = var.entorno   # <-- Aquí llamamos a la otra variable
    CreadoPor = "Terraform"
  }
}
```

Ahora aplicamos
```bash
terraform plan
terraform apply
```

La salida será la siguiente:

```bash
Apply complete! Resources: 1 added, 0 changed, 1 destroyed.

Outputs:

bucket_arn = "arn:aws:s3:::mi-bucket-parametrizado-con-variables"
bucket_domain_name = "mi-bucket-parametrizado-con-variables.s3.amazonaws.com"
```

## Nota adicional flocy
Para que floci conserve la infra creada, se debe iniciar con la siguiente opcion de persistencia
```bash
floci start --persist ./data
```

# 4. Archivo de estado tfstate
Archivo JSON donde se almacena el mapa de la infraestructura
En este caso es terraform.tfstate

## Ejemplo práctivo tfstate
En el archivo main.tf agregamos el siguiente tag:

```bash
resource "aws_s3_bucket" "mi_bucket_local" {
  bucket = var.nombre_bucket

  tags = {
    Entorno   = var.entorno
    CreadoPor = "Terraform"
    Proyecto  = "AprendizajeDevOps"  # <-- Agrega esta línea nueva
  }
}
```
Se guarda y al aplicar el plan "terraform plan" aparecera que va a hacer cambios y no crear o destruir:
~ update in-place (actualizar en el sitio)

Al aplicar "terraform apply" y revisamos el archivo tfsate se verá el nuevo tag agregado

## Tres reglas de oro en tfstate
1. Nunca se edita a mano, se utilizan los otros archivos.
2. Nunca se sube a un repo publico como GitHub, puede tener información sensible como claves.
3. Para trabajo en equipo se utiliza un almacenamiento seguro como un Bucket S3 con bloqueo de escritura.


# 5. Aseguramiento del codigo
Se actualiza el archivo .gitignore y se agregan las siguientes líneas para que no permita otros tipos de archivos

```bash
# Terraform: Ignorar los archivos de estado local (¡Seguridad primero!)
**/.terraform/*
*.tfstate
*.tfstate.*

# Ignorar archivos temporales de crash o logs
crash.log
*.log
crash.log

# Variables sensibles
*.tfvars
*.tfvars.json

# Planes de Terraform
*.tfplan

# Lock file (opcional)
# .terraform.lock.hcl

# Archivos específicos de macOS que no aportan al código
.DS_Store
```
Para que esto quede aplicado, porque se encontró el archivo terraform.tfsate en GitHub se ejecuta lo siguiente:

1. Elimina el archivo de estado de la caché de Git
```bash
git rm --cached terraform.tfstate
```

2. Si se crearon copias de seguridad de estado, elimínalas también
```bash
git rm --cached terraform.tfstate.backup
```
3. Elimina la carpeta interna de Terraform que se haya subido por error
```bash
git rm -r --cached .terraform/
```
4. Registra los cambios (esto le dirá a Git que prepare el borrado en el servidor)
```bash
git add .
```

5. Crea el commit explicando lo que hiciste
```bash
git commit -m "style: limpiar archivos temporales de terraform del repositorio"
```

6. Sube los cambios a tu rama principal en GitHub
```bash
git push origin main
```

# 6. Eliminación y persistencia
Para eliminar la infraestructura creada en terraform
```bash
terraform destroy
```
Para trabajar en floci con persistencia, o sea que lo creado no se elimine al detener floci y docker
```bash
floci start --persist ./data
```
## Nota
Para que no suba a GitHub el directorio data en donde persisten la info de floci, se agrega la siguiente línea en .gitignore:
```bash
# Ignorar la carpeta de persistencia local de Floci
data/
```
y si esta ya subió es necesario ejecutar lo siguiente para eliminarlo de GitHub
```bash
git rm -r --cached data/
git add .
git commit -m "style: ignorar carpeta de persistencia de floci"
git push origin main
```

## 7. Laboratorio 1. Terraform NGINX
Se encuentra en el directorio 02-nginx-local.
Allí se encuentra el README.md