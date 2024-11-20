terraform {
  backend "remote" {
    organization = "CI_CD"
    workspaces {
      name = "Terrafrom-CI_CD"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

# IAM Role and Policies
resource "aws_iam_role" "ec2_role" {
  name = "ec2_s3_access_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Create IAM instance profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_role.name
}

# S3 access policy
resource "aws_iam_role_policy" "s3_access_policy" {
  name = "s3_access_policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::sumit-aws-1",
          "arn:aws:s3:::sumit-aws-1/*"
        ]
      }
    ]
  })
}

# Security Group
resource "aws_security_group" "sumit-iac" {
  name        = "sumit-iac"
  description = "sumit-iac security group"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 80
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
}

# EC2 Instance
resource "aws_instance" "worker" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = true
  security_groups = [aws_security_group.sumit-iac.name]
  
  tags = {
    Name = "sumit-cloud"
  }

  # Remote Exec Provisioner
  provisioner "remote-exec" {
    inline = [
      "echo 'Updating system packages...'",
      "sudo apt-get update -y",
      "sudo apt-get install -y unzip curl",
      
      # Install AWS CLI
      "curl \"https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip\" -o \"awscliv2.zip\"",
      "unzip awscliv2.zip",
      "sudo ./aws/install",
      "aws --version",
      
      # Setup AWS credentials
      "mkdir -p ~/.aws",
      "echo '[default]' > ~/.aws/config",
      "echo 'region = ap-south-1' >> ~/.aws/config",
      "echo '[default]' > ~/.aws/credentials",
      "echo 'aws_access_key_id = ${var.aws_access_key_id}' >> ~/.aws/credentials",
      "echo 'aws_secret_access_key = ${var.aws_secret_access_key}' >> ~/.aws/credentials",
      
      # Create and setup /opt directory
      "sudo mkdir -p /opt",
      "sudo chown ubuntu:ubuntu /opt",
      
      # Copy env file from S3
      "aws s3 cp s3://sumit-aws-1/env /opt/.env",
      "sudo chmod 600 /opt/.env",
      
      # Verify setup
      "aws s3 ls",
      "ls -la /opt/.env"
    ]
    
    connection {
      type        = "ssh"
      user        = var.username
      private_key = var.private_key
      host        = self.public_ip
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
