#!/bin/bash

# set -e  # Exit on any error

# Define packages to download from standard Oracle Linux repos
PACKAGES=(
    oracle-epel-release-el8
    ansible-core
    tar
    python3
    python3-pip
    git
    unzip
    gcc
    make
    wget
)

# Pre-Prereqs for distro node
sudo yum update -y
sudo yum install -y "${PACKAGES[@]}"

# exec > >(tee /home/ec2-user/setup_bastion.log) 2>&1  # Log all outputs

# # Function to stop any process using the package manager
# stop_conflicting_processes() {
#     echo "Checking for conflicting yum/dnf processes..."
#     while pgrep -x "yum" > /dev/null || pgrep -x "dnf" > /dev/null; do
#         echo "Waiting for yum/dnf processes to stop..."
#         sleep 5
#     done
#     echo "No conflicting yum/dnf processes found."
# }

# # Stop conflicting processes before proceeding
# stop_conflicting_processes

# # Repair RPM database if corrupted
# echo "Checking and repairing the RPM database..."
# sudo rm -f /var/lib/rpm/__db.*  # Remove lock files
# sudo rpm --rebuilddb            # Rebuild the RPM database
# echo "RPM database repaired successfully."

# # Clean up yum and install required dependencies
# sudo yum clean all
# sudo yum makecache fast
# sudo yum install -y ansible-core python3.9

# # Set Python 3.9 as the default
# sudo alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 2
# sudo alternatives --set python3 /usr/bin/python3.9

# # Verify ansible-playbook exists
# if ! command -v ansible-playbook &> /dev/null; then
#     echo "Error: ansible-playbook command not found. Ansible installation failed."
#     exit 1
# fi

# # Run the Ansible playbook
# ansible-playbook -i /home/ec2-user/ansible_inventory.ini /home/ec2-user/bastion-prep.yml

# Download Confluent Offline Install Tarball using wget
 wget https://confluent-tarballs.s3.us-east-1.amazonaws.com/confluent-offline-install-7.7.1-latest.tar.gz
