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
  bucket = aws_s3_bucket.harridee.bucket

  # Static website hosting settings
  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }
}

# Optional - Redirect Rule
resource "aws_s3_object" "index_redirect" {
  bucket           = aws_s3_bucket.harridee.bucket
  key              = "index.html"
  website_redirect = "/app/index.html" # Redirect to the index.html file inside the app folder
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