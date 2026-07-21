# Módulo 03: Arquitectura Modular e Infraestructura Declarativa con Terraform

Este laboratorio documenta la transición de un despliegue monolítico a una estructura modular basada en código limpio e infraestructura como código (IaC) parametrizada.

## 🎯 Objetivos

* Desacoplar la infraestructura en archivos especializados (`providers.tf`, `variables.tf`, `outputs.tf`, `main.tf`, `terraform.tfvars`).
* Parametrizar recursos para alternar dinámicamente entre entornos (`dev` y `prod`).
* Analizar el comportamiento del motor de Terraform ante cambios *in-place* frente a *reemplazo de recursos*.
* Validar la protección del estado local (`terraform.tfstate`) mediante reglas de `.gitignore`.

---

## 📁 Estructura del Proyecto

```text
03-terraform-modular/
├── providers.tf       # Configuración del proveedor (AWS / Floci emulator)
├── variables.tf       # Declaración y tipos de variables de entrada
├── terraform.tfvars   # Valores de variables para el entorno actual
├── main.tf            # Definición principal de recursos (EC2, Security Group)
├── outputs.tf         # Definición de valores expuestos tras el despliegue
└── README.md          # Documentación del laboratorio

```

---

## 🛠️ Conceptos Clave Aprendidos

### 1. In-place Updates vs. Resource Replacement

Durante la ejecución de `terraform plan`, se evaluó la reacción del motor ante modificaciones de parámetros:

* **Modificación en sitio (*Update in-place* - `~`):** Ocurre con atributos mutables (ej. cambiar el `instance_type` de una EC2). Terraform modifica el recurso existente sin destruirlo.
* **Destrucción y Recreación (*Replace* - `-/+`):** Ocurre cuando se modifican atributos inmutables en la API del proveedor (ej. la propiedad `name` de un Security Group). Terraform fuerza la creación de un nuevo recurso y elimina el anterior (`1 to add, 1 to destroy`).

### 2. Gestión de Variables y Entornos

Se comprobó la inyección de variables utilizando `terraform.tfvars` para alternar la etiqueta del entorno y los nombres de los recursos sin editar la lógica central del `main.tf`.

---

## 🚀 Ciclo de Comandos Ejecutados

```bash
# 1. Inicializar directorio y descargar proveedores
terraform init

# 2. Validar sintaxis y formato
terraform fmt
terraform validate

# 3. Previsualizar cambios e inspeccionar el plan de ejecución
terraform plan

# 4. Aplicar cambios en el entorno simulado (Floci)
terraform apply -auto-approve

# 5. Limpieza de recursos al finalizar
terraform destroy -auto-approve

```

---

## 🛡️ Seguridad del Estado (State Hygiene)

El archivo de estado `terraform.tfstate` contiene información sensible y el mapeo del entorno. Se verificó su exclusión global mediante el archivo `.gitignore` ubicado en la raíz del repositorio para evitar fugas de información hacia GitHub.

---