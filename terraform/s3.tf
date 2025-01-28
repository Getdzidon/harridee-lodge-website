######### S3 Bucket Resource (Main Bucket Configuration) ##########
resource "aws_s3_bucket" "harridee" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = "Dev"
  }
}

# S3 Bucket Website Configuration (Enable Static Web Hosting)
resource "aws_s3_bucket_website_configuration" "harridee_website_config" {
  bucket = aws_s3_bucket.harridee.id

  # Static website hosting settings
  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }
}

# S3 Bucket Public Access Block (Unblock Public Access)
resource "aws_s3_bucket_public_access_block" "harridee_public_access" {
  bucket = aws_s3_bucket.harridee.id

  block_public_acls       = false # Allow public ACLs
  block_public_policy     = false # Allow public policies
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# S3 Bucket Policy to Allow Public Read Access to Objects
resource "aws_s3_bucket_policy" "harridee_bucket_policy" {
  bucket = aws_s3_bucket.harridee.id
  policy = <<-EOT
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "PublicReadGetObject",
          "Effect": "Allow",
          "Principal": "*",
          "Action": "s3:GetObject",
          "Resource": "arn:aws:s3:::${aws_s3_bucket.harridee.id}/*"
        }
      ]
    }
  EOT
}