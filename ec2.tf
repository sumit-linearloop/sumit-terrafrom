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
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}

# Create an EC2 instance
resource "aws_instance" "worker" {
  ami           = var.ami            # Reference the AMI variable
  instance_type = var.instance_type  # Reference the instance type variable
  key_name      = var.key_name       # Reference the SSH key pair variable
 
  # Add security group
  security_groups = [aws_security_group.sumit-iac.name]

  # Use cloud-init or a shell script for initial setup
  user_data = file("${path.module}/sumit.sh")  # Ensure this script is in the correct location

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
    protocol    = "-1"           # Use "-1" to allow all protocols
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }
}

# Output the public IP of the EC2 instance
output "instance_public_ip" {
  value = aws_instance.worker.public_ip
}





# terraform {
#   backend "remote" {
#     organization = "CI_CD"
#     workspaces {
#       name = "Terrafrom-CI_CD"
#     }
#   }
# }

# provider "aws" {
#   region     = "ap-south-1"
# }

# # Security Group
# resource "aws_security_group" "sumit-iac" {
#   name        = "sumit-iac"
#   description = "Security Group for EC2 instance"

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere
#   }

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"] # Allow HTTP from anywhere
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
#   }
# }

# # EC2 Instance
# resource "aws_instance" "worker" {
#   ami           = var.ami
#   instance_type = var.instance_type
#   key_name      = var.key_name
#   security_groups = [aws_security_group.sumit-iac.name]

#   tags = {
#     Name = "sumit-cloud"
#   }

#   # Upload the shell script to the instance
#   provisioner "file" {
#     source      = "./sumit.sh" # Path to your local script
#     destination = "/home/ubuntu/sumit.sh" # Destination path on the instance
#   }

#   connection {
#     type        = "ssh"
#     host        = self.public_ip
#     user        = "ubuntu" # Update to ubuntu for Ubuntu AMI
#     private_key = var.ssh_private_key # Use variable directly
#   }

# provisioner "remote-exec" {
#   inline = [
#     "chmod +x /home/ubuntu/sumit.sh",
#     "sudo /home/ubuntu/sumit.sh"
#   ]

#     connection {
#       type        = "ssh"
#       host        = self.public_ip
#       user        = "ubuntu" # Use ubuntu user
#       private_key = var.ssh_private_key # Use variable directly
#     }
#   }
# }

# # Output the instance public IP
# output "instance_public_ip" {
#   value = aws_instance.worker.public_ip
# }
