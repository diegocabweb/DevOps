# Obtener la AMI más reciente de Amazon Linux 2023
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# Obtener la VPC por defecto
data "aws_vpc" "default" {
  default = true
}

# Obtener las subnets de la VPC por defecto
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Grupo de Seguridad
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

# Instancia EC2 (usando terraform.workspace para variar según el entorno)
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