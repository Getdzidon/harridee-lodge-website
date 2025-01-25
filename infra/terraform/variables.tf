# Variables for customization

variable "region" {
  default     = "eu-central-1"
  description = "AWS region to deploy resources"
}
variable "ami" {
  description = "The AMI ID  to use for this instance."
  type        = string
  default     = "ami-07eef52105e8a2059"
}

variable "vpc_id" {
  description = "ID of the default vpc"
  default     = "vpc-0528dc4e6cbc1eb6c"
}

variable "instance_type" {
  default     = "t2.micro"
  description = "Instance type for the EC2 instance"
}

variable "instance_name" {
  default     = "harridee"
  description = "Name of EC2 instance"
}

variable "key_name" {
  default     = "Jomacs Demo"
  description = "Name of the key pair to use for the EC2 instance"
}

variable "instance_count" {
  description = "The number of instances to launch."
  type        = number
  default     = 1
}

variable "bucket_name" {
  default     = "harridee"
  description = "Name of the S3 bucket"
}