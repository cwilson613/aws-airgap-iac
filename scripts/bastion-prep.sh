#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Update and upgrade the system
echo "Updating system packages..."
sudo yum update -y

# Install EPEL repository
echo "Installing EPEL repository..."
sudo yum install -y epel-release

# Install basic utilities
echo "Installing basic utilities..."
sudo yum install -y wget curl unzip tar vim git net-tools bind-utils telnet nc jq

# Install Python and pip
echo "Installing Python and pip..."
sudo yum install -y python3 python3-pip

# Upgrade pip and install required Python modules
echo "Upgrading pip and installing Python modules..."
sudo pip3 install --upgrade pip
sudo pip3 install ansible-core jmespath

# Configure SELinux to permissive mode
#echo "Configuring SELinux to permissive mode..."
#sudo setenforce 0
#sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/' /etc/selinux/config

# Configure Firewall
#echo "Configuring firewall rules..."
#sudo firewall-cmd --permanent --add-port=22/tcp  # SSH
#sudo firewall-cmd --permanent --add-port=80/tcp  # HTTP (if needed)
#sudo firewall-cmd --permanent --add-port=443/tcp # HTTPS (if needed)
#sudo firewall-cmd --reload

# Configure hostname (adjust <your-hostname> as needed)
echo "Configuring hostname..."
sudo hostnamectl set-hostname bastion

# Create a user for administrative tasks
#echo "Creating a new user 'bastion'..."
#sudo useradd bastion
#sudo mkdir -p /home/bastion/.ssh
#sudo chmod 700 /home/bastion/.ssh

# Add your SSH public key (adjust path to your public key)
#echo "Adding SSH public key for 'bastion' user..."
#sudo bash -c 'cat <<EOF > /home/bastion/.ssh/authorized_keys
#<your-ssh-public-key>
#EOF'
#sudo chmod 600 /home/bastion/.ssh/authorized_keys
#sudo chown -R bastion:bastion /home/bastion/.ssh

# Ensure the bastion user has sudo privileges
#echo "Granting sudo privileges to 'bastion' user..."
#sudo bash -c 'echo "bastion ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/bastion'
#sudo chmod 440 /etc/sudoers.d/bastion

# Verify and finalize the setup
#echo "Setup complete. Verifying system configuration..."
#echo "Firewall Rules:"
#sudo firewall-cmd --list-all
#echo "SELinux Status:"
#sestatus
#echo "Bastion setup is ready."
