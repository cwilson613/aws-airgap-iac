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

# Create a route table for the private subnet (no internet route)
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.confluent_vpc.id

  # No default route to the internet
  tags = {
    Name = "private_route_table"
  }
}

# Associate the private subnet with its route table
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}


# Create a new security group for the bastion host
resource "aws_security_group" "connected_bastion_sg" {
  name        = "connected_bastion_sg"
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
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "connected_bastion_sg"
  }
}

# Create a security group
# Modify security group for Confluent instances to allow SSH only from the Bastion host
resource "aws_security_group" "confluent_sg" {
  name        = "confluent_sg"
  description = "Security group for Confluent instances"
  vpc_id      = aws_vpc.confluent_vpc.id

  # Allow all internal traffic (private and public subnet origin)
  ingress {
    description = "SSH from all subnets"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.public_subnet_cidr, var.private_subnet_cidr]
  }

  # Egress open without internet access (airgapped)
  egress {
    description = "Allow outbound access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "confluent_sg"
  }
}

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

# EC2 Instances per Role

# Kafka Controller
resource "aws_instance" "kafka_controller" {
  ami                         = var.oracle_ami_id
  instance_type               = var.kafka_controller_instance_type # 32 vCPUs, 64GB RAM
  subnet_id                   = aws_subnet.private_subnet.id
  vpc_security_group_ids      = [aws_security_group.confluent_sg.id]
  associate_public_ip_address = false
  key_name                    = data.aws_key_pair.confluent_key_pair.key_name

  root_block_device {
    volume_size = 2048 # 4TB SSD
    volume_type = "gp3"
  }

  # Remove internet-required yum repos using remote-exec
  provisioner "remote-exec" {
    inline = [
      "sudo systemctl stop firewalld",
      "sudo systemctl disable firewalld --now",
      "sudo rm -f /etc/yum.repos.d/*.repo",
      "sudo yum clean all"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = data.local_file.private_key.content # Use the generated key for connecting
      host        = self.private_ip

      bastion_host        = aws_instance.bastion.public_ip
      bastion_user        = "ec2-user"                          # User for the bastion host
      bastion_private_key = data.local_file.private_key.content # Private key for the bastion host
    }
  }

  tags = {
    Name = "${var.user}-kafka-controller"
    Role = "kafka_controller"
  }
}

# Kafka Broker
resource "aws_instance" "kafka_broker" {
  ami                         = var.oracle_ami_id
  instance_type               = var.kafka_broker_instance_type # 4 vCPUs, 32GB RAM
  subnet_id                   = aws_subnet.private_subnet.id
  vpc_security_group_ids      = [aws_security_group.confluent_sg.id]
  associate_public_ip_address = false
  key_name                    = data.aws_key_pair.confluent_key_pair.key_name

  root_block_device {
    volume_size = 500 # 500GB SSD
    volume_type = "gp3"
  }

  # Remove internet-required yum repos using remote-exec
  provisioner "remote-exec" {
    inline = [
      "sudo systemctl stop firewalld",
      "sudo systemctl disable firewalld --now",
      "sudo rm -f /etc/yum.repos.d/*.repo",
      "sudo yum clean all"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = data.local_file.private_key.content # Use the generated key for connecting
      host        = self.private_ip

      bastion_host        = aws_instance.bastion.public_ip
      bastion_user        = "ec2-user"                          # User for the bastion host
      bastion_private_key = data.local_file.private_key.content # Private key for the bastion host
    }
  }

  tags = {
    Name = "${var.user}-kafka-broker"
    Role = "kafka_broker"
  }
}

# Control Center
resource "aws_instance" "control_center" {
  ami                         = var.oracle_ami_id
  instance_type               = var.control_instance_type # 8 vCPUs, 32GB RAM
  subnet_id                   = aws_subnet.private_subnet.id
  vpc_security_group_ids      = [aws_security_group.confluent_sg.id]
  associate_public_ip_address = false
  key_name                    = data.aws_key_pair.confluent_key_pair.key_name

  root_block_device {
    volume_size = 300 # 300GB SSD
    volume_type = "gp3"
  }

  # Provisioner to copy the private key to the bastion host
  # 
  #   
  provisioner "file" {
    source      = data.local_file.private_key.filename
    destination = "/home/ec2-user/cog-team.pem"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = data.local_file.private_key.content # Use the generated key for connecting
      host        = self.private_ip

      bastion_host        = aws_instance.bastion.public_ip
      bastion_user        = "ec2-user"                          # User for the bastion host
      bastion_private_key = data.local_file.private_key.content # Private key for the bastion host
    }
  }

  # Remove internet-required yum repos using remote-exec
  # Add private key to control node for SSH
  provisioner "remote-exec" {
    inline = [
      "chmod 600 /home/ec2-user/cog-team.pem",
      "chown ec2-user:ec2-user /home/ec2-user/cog-team.pem",
      "sudo systemctl stop firewalld",
      "sudo systemctl disable firewalld --now",
      "sudo rm -f /etc/yum.repos.d/*.repo",
      "sudo yum clean all"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = data.local_file.private_key.content # Use the generated key for connecting
      host        = self.private_ip

      bastion_host        = aws_instance.bastion.public_ip
      bastion_user        = "ec2-user"                          # User for the bastion host
      bastion_private_key = data.local_file.private_key.content # Private key for the bastion host
    }
  }

  tags = {
    Name = "${var.user}-control-center"
    Role = "control_center"
  }
}

# Schema Registry
resource "aws_instance" "schema_registry" {
  ami                         = var.oracle_ami_id
  instance_type               = var.schema_registry_instance_type # 16 vCPUs, 32GB RAM
  subnet_id                   = aws_subnet.private_subnet.id
  vpc_security_group_ids      = [aws_security_group.confluent_sg.id]
  associate_public_ip_address = false
  key_name                    = data.aws_key_pair.confluent_key_pair.key_name

  root_block_device {
    volume_size = 300 # 300GB SSD
    volume_type = "gp3"
  }

  # Remove internet-required yum repos using remote-exec
  provisioner "remote-exec" {
    inline = [
      "sudo systemctl stop firewalld",
      "sudo systemctl disable firewalld --now",
      "sudo rm -f /etc/yum.repos.d/*.repo",
      "sudo yum clean all"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = data.local_file.private_key.content # Use the generated key for connecting
      host        = self.private_ip

      bastion_host        = aws_instance.bastion.public_ip
      bastion_user        = "ec2-user"                          # User for the bastion host
      bastion_private_key = data.local_file.private_key.content # Private key for the bastion host
    }
  }

  tags = {
    Name = "${var.user}-schema-registry"
    Role = "schema_registry"
  }
}

# ksqlDB
resource "aws_instance" "ksql" {
  ami                         = var.oracle_ami_id
  instance_type               = var.ksql_instance_type # 8 vCPUs, 32GB RAM
  subnet_id                   = aws_subnet.private_subnet.id
  vpc_security_group_ids      = [aws_security_group.confluent_sg.id]
  associate_public_ip_address = false
  key_name                    = data.aws_key_pair.confluent_key_pair.key_name

  root_block_device {
    volume_size = 300 # 300GB SSD
    volume_type = "gp3"
  }

  # Remove internet-required yum repos using remote-exec
  provisioner "remote-exec" {
    inline = [
      "sudo systemctl stop firewalld",
      "sudo systemctl disable firewalld --now",
      "sudo rm -f /etc/yum.repos.d/*.repo",
      "sudo yum clean all"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = data.local_file.private_key.content # Use the generated key for connecting
      host        = self.private_ip

      bastion_host        = aws_instance.bastion.public_ip
      bastion_user        = "ec2-user"                          # User for the bastion host
      bastion_private_key = data.local_file.private_key.content # Private key for the bastion host
    }
  }

  tags = {
    Name = "${var.user}-ksql"
    Role = "ksql"
  }
}

# Create a Bastion EC2 instance (Amazon Linux)
resource "aws_instance" "bastion" {
  ami                         = var.oracle_ami_id
  instance_type               = var.bastion_instance_type
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.connected_bastion_sg.id]
  associate_public_ip_address = true # Bastion needs public access
  key_name                    = data.aws_key_pair.confluent_key_pair.key_name

  root_block_device {
    volume_size = 256   # Change this to your desired size in GB
    volume_type = "gp3" # Can be gp2, gp3, io1, etc.
  }

  # Provisioner to copy the private key to the bastion host
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

  # Provisioner to copy the dependency collection script to the bastion host
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
    Name = "${var.user}-confluent-distribution-node"
  }
}
