variable "codestar_connection_arn" {
  description = "ARN der CodeStar-Connection für GitHub"
  type        = string
}

variable "aws_region" {
  description = "AWS-Region, in der die Ressourcen erstellt werden sollen"
  default     = "eu-central-1"
  type        = string
}

variable "ec2_ami" {
  description = "AMI-ID für die EC2-Instanz"
  type        = string
  default     = "ami-03cceb19496c25679"
}

