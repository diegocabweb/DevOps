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
