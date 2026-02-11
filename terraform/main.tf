provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "game_server" {
  ami           = "ami-0c83cb1c664994bbd" 
  instance_type = "t3.small"
  key_name      = "monz"

  security_groups = [aws_security_group.mygame.name]

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install nginx -y
              systemctl start nginx
              systemctl enable nginx
              EOF

  tags = {
    Name = "Game-Server"
  }
}

resource "aws_security_group" "mygame" {
  name = "mygame"

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
output "public_ip" {
  value = aws_instance.game_server.public_ip
}
