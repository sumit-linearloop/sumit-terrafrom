terraform {
  backend "remote" {
    organization = "CI_CD"
    workspaces {
      name = "Terrafrom-CI_CD"
    }
  }
}

provider "aws" {
  region     = "ap-south-1"
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

# Security Group
resource "aws_security_group" "sumit-iac" {
  name        = "sumit-iac"
  description = "sumit-iac security group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Restrict this in production (change to a specific IP)
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP from anywhere (change as needed)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "worker" {
  ami                    = var.ami             # Ensure this is the correct Ubuntu AMI ID
  instance_type          = var.instance_type   # Example: "t2.micro"
  key_name               = var.key_name        # Your existing SSH key
  associate_public_ip_address = true
  security_groups        = [aws_security_group.sumit-iac.name]

  tags = {
    Name = "sumit-cloud"
  }

  # Remote Exec Provisioner to Install and Configure AWS CLI
  provisioner "remote-exec" {
    inline = [
      "echo 'Updating system packages...'",
      "sudo apt-get update -y",                    # Update system packages
      "sudo apt-get install -y unzip curl",         # Install unzip and curl (needed for AWS CLI installation)
      "curl \"https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip\" -o \"awscliv2.zip\"",
      "unzip awscliv2.zip",                         # Unzip the AWS CLI installer
      "sudo ./aws/install",                         # Install AWS CLI
      "aws --version",                              # Verify the AWS CLI installation
      
      # AWS CLI configuration
      "aws configure set aws_access_key_id ${var.aws_access_key_id}",  # Set AWS Access Key ID
      "aws configure set aws_secret_access_key ${var.aws_secret_access_key}",  # Set AWS Secret Access Key
      "aws configure set region ${var.aws_region}"  # Set AWS region (make sure to define aws_region in your variables.tf)

      # AWS S3 Commands
      "aws s3 ls s3://sumit-aws-1/env",             # List the contents of the specified S3 bucket
      "aws s3 cp s3://sumit-aws-1/env /opt/.env",    # Copy .env file from S3 to /opt/.env
      "ls -l /opt/.env"                             # List the details of the .env file in /opt directory
    ]

    connection {
      type        = "ssh"
      user        = var.username              # Ensure this is "ubuntu" for Ubuntu instances
      private_key = var.private_key           # The private SSH key
      host        = self.public_ip            # EC2 public IP for SSH connection
    }
  }
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
