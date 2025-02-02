###################### Security Group Resource ######################
resource "aws_security_group" "default_vpc_sg" {
  name        = "${var.instance_name}-sg"
  description = "Allow SSH and HTTP access"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #This is not allowed in Production or any enterprise environment
  }

  ingress {
    from_port   = 80 # http
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

  tags = {
    Name = "${var.instance_name}-sg"
  }
}

# Reference the default VPC dynamically
data "aws_vpc" "default" {
  default = true
}