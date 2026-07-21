resource "aws_security_group" "web_sg" {
  name        = "sg_${var.environment}_web"
  description = "Security group para el servidor web en ${var.environment}"

  ingress {
    from_port   = var.http_port
    to_port     = var.http_port
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
    Name        = "sg-${var.environment}-web"
    Environment = var.environment
  }
}

resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0" # Amazon Linux 2023
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name        = "ec2-${var.environment}-web"
    Environment = var.environment
  }
}