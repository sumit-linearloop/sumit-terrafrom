variable "ami" {
  description = "AMI ID for the EC2 instance"
  type        = string
}
 
variable "instance_type" {
  description = "Type of EC2 instance"
  type        = string
}
 
variable "key_name" {
  description = "Name of the SSH key"
  type        = string
}

variable "ssh_private_key" {
  description = "Path to the private key file for SSH connection"
  type        = string
}

variable "AWS_ACCESS_KEY_ID" {
  type        = string
  description = "AWS Access Key ID"
}

variable "AWS_SECRET_ACCESS_KEY" {
  type        = string
  description = "AWS Secret Access Key"
}
