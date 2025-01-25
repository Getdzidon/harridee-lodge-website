terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.84.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Security Group Resource
resource "aws_security_group" "default_vpc_sg" {
  name        = "${var.instance_name}-sg"
  description = "Allow SSH and HTTP access"
  vpc_id      = data.aws_vpc.default.id # Reference the default VPC dynamically

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }

  tags = {
    Name = "${var.instance_name}-sg"
  }
}

# Reference the default VPC dynamically
data "aws_vpc" "default" {
  default = true
}

# EC2 Instance Resource
resource "aws_instance" "example" {
  ami                    = var.ami            # Reference a variable for AMI
  instance_type          = var.instance_type  # Reference a variable for instance type
  count                  = var.instance_count # Reference a variable for key pair
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.default_vpc_sg.id] # Use the existing SG
  tags = {
    Name = var.instance_name
  }
}


# S3 Bucket Resource
resource "aws_s3_bucket" "harridee" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = "Dev"
  }
}

# Outputs for useful information
output "security_group_id" {
  description = "The ID of the created security group"
  value       = aws_security_group.default_vpc_sg.id
}

output "instance_ids" {
  description = "The ID of the created EC2 instance"
  value       = [for instance in aws_instance.example : instance.id]
}

output "instance_public_ips" {
  description = "The public IP of the created EC2 instance"
  value       = [for instance in aws_instance.example : instance.public_ip]
}

output "s3_bucket_name" {
  description = "The name of the created S3 bucket"
  value       = aws_s3_bucket.harridee
}
