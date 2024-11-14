# Security Group
resource "aws_security_group" "sumit-iac" {
  name        = "sumit-iac"
  description = "sumit-iac"

  dynamic "ingress" {
    for_each = [22, 80, 443, 6379]
    iterator = port
    content {
      description = "TLS from VPC"
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Sumit-Terraform"
  }
}

# Key Pair
resource "aws_key_pair" "id_rsa" {
  key_name   = "id_rsa"
  public_key = file("${path.module}/id_rsa.pub")
}

# EC2 Instance
resource "aws_instance" "worker" {
  ami                    = "ami-0dee22c13ea7a9a67"
  instance_type          = "t2.nano"
  key_name               = aws_key_pair.id_rsa.key_name
  vpc_security_group_ids = ["${aws_security_group.sumit-iac.id}"]

  tags = {
    Name = "BetterBugs-kub-worker"
  }
}