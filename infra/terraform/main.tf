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

###################### Security Group Resource ######################
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

###################### EC2 Instance Resource ######################
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

#################### S3 Bucket Resource (Main Bucket Configuration) ####################
resource "aws_s3_bucket" "harridee" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = "Dev"
  }
}

# S3 Bucket Website Configuration (Enable Static Web Hosting)
resource "aws_s3_bucket_website_configuration" "harridee_website_config" {
  bucket = aws_s3_bucket.harridee.bucket

  # Static website hosting settings
  index_document {
    suffix = "app/index.html"
  }

  error_document {
    key = "app/404.html"
  }
}

# S3 Bucket Public Access Block (Unblock Public Access)
resource "aws_s3_bucket_public_access_block" "harridee_public_access" {
  bucket = aws_s3_bucket.harridee.bucket

  block_public_acls       = false # Allow public ACLs
  block_public_policy     = false # Allow public policies
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# S3 Bucket Policy to Allow Public Read Access to Objects
resource "aws_s3_bucket_policy" "harridee_bucket_policy" {
  bucket = aws_s3_bucket.harridee.bucket
  policy = <<-EOT
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "PublicReadGetObject",
          "Effect": "Allow",
          "Principal": "*",
          "Action": "s3:GetObject",
          "Resource": "arn:aws:s3:::${aws_s3_bucket.harridee.bucket}/*"
        }
      ]
    }
  EOT
}

########################## CloudFront Distribution Resource ##########################
# CloudFront Origin Access Control (Define it explicitly)
resource "aws_cloudfront_origin_access_control" "default" {
  name                              = "default-oac"
  description                       = "Default Origin Access Control for CloudFront"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.harridee.bucket_regional_domain_name
    origin_id                = "S3Origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for ${var.bucket_name}"
  default_root_object = "app/index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3Origin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = "Dev"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

############ Outputs for useful information  ##############
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
  value       = aws_s3_bucket.harridee.bucket
}

output "cloudfront_distribution_domain" {
  description = "The CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "s3_bucket_website_url" {
  description = "The URL of the static website"
  value       = "http://${aws_s3_bucket.harridee.bucket}.s3-website-${var.region}.amazonaws.com"
}
