resource "aws_instance" "example" {
  ami           = var.ec2_ami
  instance_type = "t2.micro"
  key_name      = "ansible"
  tags = {
    key   = "Name"
    value = "httpd-instance"
  }
  

  security_groups = ["allow_ssh_http"]
  iam_instance_profile = aws_iam_instance_profile.ec2_role.name

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

resource "aws_iam_policy" "s3_access_policy" {
  name = "ec2_codepipeline_s3_access"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": [
        "${aws_s3_bucket.codepipeline_bucket.arn}",
        "${aws_s3_bucket.codepipeline_bucket.arn}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2_codepipeline_s3_access"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"]

  inline_policy {
    name = "s3_access_policy"
    policy = aws_iam_policy.s3_access_policy.policy
  }
}

resource "aws_iam_instance_profile" "ec2_role" {
  name = "ec2_codepipeline_s3_access"
  role = aws_iam_role.ec2_role.name
}
