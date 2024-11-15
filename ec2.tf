terraform {
  backend "remote" {
    organization = "CI_CD"
    workspaces {
      name = "Terrafrom-CI_CD"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

# Create an EC2 instance
resource "aws_instance" "worker" {
  ami           = var.ami            # Reference the AMI variable
  instance_type = var.instance_type  # Reference the instance type variable
  key_name      = var.key_name       # Reference the SSH key pair variable
 
  # Add security group
  security_groups = [aws_security_group.sumit-iac.name]
 
  tags = {
    Name = "sumit-cloud"
  }
}
 
# Create a Security Group (SG) for the EC2 instance
resource "aws_security_group" "sumit-iac" {
  name        = "sumit-iac"
  description = "sumit-iac"
 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from anywhere
  }
 
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP from anywhere
  }
 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }
}
 
output "instance_public_ip" {
  value = aws_instance.worker.public_ip
}