resource "aws_instance" "example" {
  ami           = var.ec2_ami
  instance_type = "t2.micro"
  key_name      = "ansible"
  tags = {
    key   = "Name"
    value = "httpd-instance"
  }

  security_groups = ["allow_ssh_http"]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              sudo systemctl start httpd
              sudo systemctl enable httpd
              sudo yum install -y ruby
              sudo yum install -y wget
              cd /home/ec2-user
              wget https://aws-codedeploy-${var.aws_region}.s3.amazonaws.com/latest/install
              chmod +x ./install
              ./install auto
              EOF
}

resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP inbound traffic"

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
