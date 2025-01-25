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
