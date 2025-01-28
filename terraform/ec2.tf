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