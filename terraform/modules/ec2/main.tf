variable "env" {}
variable "key_name" {}
variable "ami_id" { default = "ami-0c02fb55956c7d316" }

resource "aws_security_group" "app_sg" {
  name        = "cloudopshub-${var.env}-sg"
  description = "Allow HTTP, HTTPS, SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3000
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }

  user_data = <<-SCRIPT
    #!/bin/bash
    yum update -y
    amazon-linux-extras install docker -y
    service docker start
    usermod -a -G docker ec2-user
    curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
  SCRIPT

  tags = {
    Name        = "cloudopshub-${var.env}"
    Project     = "CloudOpsHub"
    Environment = var.env
    Team        = "GroupF"
  }
}

output "public_ip"   { value = aws_instance.app.public_ip }
output "instance_id" { value = aws_instance.app.id }
