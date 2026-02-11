provider "aws" {
  region = "eu-north-1"
}

# Get Latest Ubuntu AMI Automatically
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Security Group
resource "aws_security_group" "monigame" {
  name        = "monigame"
  description = "Allow HTTP and SSH"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

# EC2 Instance
resource "aws_instance" "monigame" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  key_name      = "M"

  vpc_security_group_ids = [aws_security_group.monigame.id]

  user_data = <<-EOT
    #!/bin/bash
    apt update -y
    apt install nginx -y
    systemctl start nginx
    systemctl enable nginx
  EOT

  tags = {
    Name = "monigame"
  }
}

# Output Public IP
output "public_ip" {
  value = aws_instance.monigame.public_ip
}
