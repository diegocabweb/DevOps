# Local EC2 Automation with Terraform & Floci

Este proyecto forma parte de mi ruta de especialización en Automatización de Infraestructura y MLOps. Consiste en la provisión automatizada de una instancia virtual de cómputo (EC2) sobre un emulador local de AWS (Floci), configurando un servidor web Nginx funcional desde el arranque mediante scripts de inicialización (`user_data`).

## 🚀 Arquitectura del Laboratorio

La infraestructura se define completamente como código (IaC) e incluye:
* **Provider:** AWS (simulado localmente en `http://localhost:4566`).
* **Compute:** 1 Instancia EC2 basada en **Amazon Linux 2023** (Arquitectura nativa `aarch64` para Apple Silicon).
* **Security:** 1 Security Group (Firewall) con reglas de entrada explícitas para SSH (Puerto 22) y HTTP (Puerto 80).
* **Provisioning:** Script Bash (`user_data`) automatizado para la instalación y despliegue del Middleware (Nginx).

---

## 🛠️ Tecnologías Utilizadas

* **Infrastructure as Code:** Terraform >= 1.0
* **Local Cloud Emulator:** Floci / LocalStack (Docker-based)
* **OS Target:** Amazon Linux 2023
* **Middleware:** Nginx

---

## 🔧 Despliegue Paso a Paso

1. **Inicializar el entorno de Terraform:**
   Descarga los proveedores de Hashicorp necesarios para la ejecución.
```bash
terraform init
```

2. **Validar el plan de ejecución:**
   Verifica los recursos (Security Group e Instancia EC2) que serán creados.
```bash
terraform plan
```

3. **Aplicar la infraestructura:**
   Despliega los recursos de forma automatizada.
```bash
terraform apply -auto-approve
```

4. **Identificar el mapeo de puertos local:**
   Dado que el entorno corre sobre contenedores emulados, Docker redirige el tráfico del puerto HTTP (80) interno hacia un puerto alto en el host local a través de un proxy `socat`. Identifica el puerto ejecutando:
```bash
docker ps
```
   *Busca el puerto mapeado para el contenedor `alpine/socat` (ej. `0.0.0.0:30000->80/tcp`)*.

5. **Prueba de acceso:**
   Valida el correcto funcionamiento del servidor web desde tu navegador o terminal:
```bash
curl http://127.0.0.1:30000
```

6. **Destrucción del entorno (FinOps):**
   Limpia el entorno local para liberar recursos del procesador.
```bash
terraform destroy -auto-approve
```

---

## 🧠 Desafíos Técnicos y Aprendizajes (Troubleshooting)

* **Compatibilidad de Gestores de Paquetes:** La imagen base simulada utiliza **Amazon Linux 2023**, lo que requirió migrar la lógica tradicional de Debian/Ubuntu (`apt-get`) hacia el gestor de paquetes moderno de RedHat (`dnf`).
* **Ausencia de Systemd en Entornos de Contenedores:** Al correr la instancia de simulación dentro de una arquitectura Docker-in-Docker, el sistema no se inicializa con `systemd` como PID 1. Esto bloqueaba el uso tradicional de `systemctl start nginx`. 
* **Solución Aplicada:** Se optimizó el script de `user_data` para invocar directamente el binario de `nginx` en segundo plano, convirtiéndolo en un despliegue portable para emuladores ligeros.
* **Control de Dependencias:** El repositorio mantiene un estricto control del archivo de bloqueo de dependencias criptográficas `.terraform.lock.hcl`, garantizando la inmutabilidad y repetibilidad del entorno en cualquier máquina.
