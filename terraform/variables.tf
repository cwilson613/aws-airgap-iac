variable "aws_region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "us-east-1"
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 3
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidr" {
  description = "Private subnet CIDR block"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_cidr" {
  description = "Private subnet CIDR block"
  type        = string
  default     = "10.0.2.0/24"
}

# variable "key_pair_name" {
#   description = "Name of the existing AWS Key Pair to use for EC2 instances"
#   type        = string
# }

variable "allowed_ssh_cidr" {
  description = "CIDR block for SSH access"
  type        = string
  default     = "0.0.0.0/0"
}

variable "user" {
  description = "User for naming differentiation"
  type        = string
}
