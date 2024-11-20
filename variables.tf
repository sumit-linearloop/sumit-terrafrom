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


variable "private_key" {
  description = "Private key for SSH access"
}

variable "username" {
  description = "The SSH username"
  type        = string
  default     = "ubuntu"
}
