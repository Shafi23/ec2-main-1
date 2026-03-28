terraform {
  backend "s3" {
    bucket = "nova-tf-state907081"
    key    = "ec2/terraform.tfstate"
    region = "ap-south-1"
  }
}


resource "aws_security_group" "mysg" {
name = "tom-sg"

ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "random_string" "mtstring" {
  length  = 10
  special = false
  upper   = false

}

resource "aws_instance" "myinstance" {
  ami           = var.myami
  instance_type = var.myinstance
    lifecycle {
    create_before_destroy = true
  }
  security_groups = [aws_security_group.mysg.name]
  user_data     = <<-EOF
              #!/bin/bash
              apt update -y
              apt install nginx -y
              echo "<html><body><h1>Welcome to Terraform</h1></body></html>" > /var/www/html/index.html
              systemctl start nginx
              systemctl enable nginx
              EOF
  tags = {
    Name = "tom-${random_string.mtstring.result}"
  }
}