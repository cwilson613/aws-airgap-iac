# Create a VPC
resource "aws_vpc" "confluent_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "confluent_vpc"
  }
}

# Create a private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.confluent_vpc.id
  cidr_block              = var.private_subnet_cidr
  map_public_ip_on_launch = false
  tags = {
    Name = "private_subnet"
  }
}

# Create a public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.confluent_vpc.id
  cidr_block              = var.public_subnet_cidr # You can define a smaller range
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "confluent_igw" {
  vpc_id = aws_vpc.confluent_vpc.id
  tags = {
    Name = "confluent_igw"
  }
}

# Create a route table for public access
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.confluent_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.confluent_igw.id
  }

  tags = {
    Name = "public_route_table"
  }
}

# Associate the public subnet with the route table
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create a new security group for the bastion host
resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
  description = "Security group for Bastion host"
  vpc_id      = aws_vpc.confluent_vpc.id

  # Allow SSH from anywhere to the bastion host
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow ICMP (ping) from anywhere"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound internet access from the bastion host
  egress {
    description = "Allow internet access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion_sg"
  }
}

# Create a security group
# Modify security group for Confluent instances to allow SSH only from the Bastion host
resource "aws_security_group" "confluent_sg" {
  name        = "confluent_sg"
  description = "Security group for Confluent instances"
  vpc_id      = aws_vpc.confluent_vpc.id

  # Allow SSH only from the Bastion host
  ingress {
    description = "SSH from Bastion host"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.public_subnet_cidr]
  }

  # Allow all traffic within the security group
  ingress {
    description = "Allow all within SG"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  # Egress rules to deny internet access (airgapped)
  egress {
    description      = "Deny all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = []
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
  }

  tags = {
    Name = "confluent_sg"
  }
}

# # Generate a new private key
# resource "tls_private_key" "confluent_key" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# Create the AWS Key Pair using the generated private key
data "aws_key_pair" "confluent_key_pair" {
  key_name = "cog-team"
  #   public_key = tls_private_key.confluent_key.public_key_openssh
}

# Save the private key locally
data "local_file" "private_key" {
  #   content  = tls_private_key.confluent_key.private_key_pem
  filename = "${path.module}/cog-team.pem"

}

# # Use a null_resource with a local-exec provisioner to set the file permissions
# resource "null_resource" "set_key_permissions" {
#   depends_on = [local_file.private_key]

#   provisioner "local-exec" {
#     command = "chmod 600 ${data.local_file.private_key.filename}"
#   }
# }

# Create EC2 instances
resource "aws_instance" "confluent_instances" {
  count = var.instance_count
  #   ami                         = "ami-0c94855ba95c71c99" # Amazon Linux 2 AMI
  ami                         = "ami-09efeab7e5627931e" # Oracle Linux AMI
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.private_subnet.id
  vpc_security_group_ids      = [aws_security_group.confluent_sg.id]
  associate_public_ip_address = false
  key_name                    = data.aws_key_pair.confluent_key_pair.key_name

  tags = {
    Name = "${var.user}-confluent-node-${count.index + 1}"
  }
}

# Create a Bastion EC2 instance (Amazon Linux)
resource "aws_instance" "bastion_instance" {
  ami = "ami-09efeab7e5627931e"
  #   ami                         = "ami-0c94855ba95c71c99" # Amazon Linux 2 AMI
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true # Bastion needs public access
  key_name                    = data.aws_key_pair.confluent_key_pair.key_name

  # Provisioners to copy the private key to the bastion host
  provisioner "file" {
    source      = data.local_file.private_key.filename
    destination = "/home/ec2-user/cog-team.pem"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = data.local_file.private_key.content # Use the generated key for connecting
      host        = self.public_ip
    }
  }

  # Provisioners to copy the private key to the bastion host
  provisioner "file" {
    source      = "${path.module}/../scripts/confluent-deps.sh"
    destination = "/home/ec2-user/confluent-deps.sh"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = data.local_file.private_key.content # Use the generated key for connecting
      host        = self.public_ip
    }
  }

  # Set permissions on the key using remote-exec
  provisioner "remote-exec" {
    inline = [
      "chmod 600 /home/ec2-user/cog-team.pem",
      "chown ec2-user:ec2-user /home/ec2-user/cog-team.pem"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = data.local_file.private_key.content # Use the generated key for connecting
      host        = self.public_ip
    }
  }

  tags = {
    Name = "${var.user}-confluent-bastion"
  }
}
