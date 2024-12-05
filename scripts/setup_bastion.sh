#!/bin/bash

set -e  # Exit on any error

# Function to stop any process using the package manager
stop_conflicting_processes() {
    echo "Checking for conflicting processes..."
    # Check for any running yum or dnf processes
    local yum_processes
    yum_processes=$(ps aux | grep -E 'yum|dnf' | grep -v grep)

    if [[ -n "$yum_processes" ]]; then
        echo "Found conflicting processes:"
        echo "$yum_processes"
        echo "Stopping conflicting processes..."
        # Kill the processes
        ps aux | grep -E 'yum|dnf' | grep -v grep | awk '{print $2}' | xargs -r sudo kill -9
        echo "Conflicting processes stopped."
    else
        echo "No conflicting processes found."
    fi
}

# Stop conflicting processes before proceeding
stop_conflicting_processes

# Clean up yum and install required dependencies
sudo yum clean all
sudo yum install -y ansible-core
sudo yum install -y python3.9

# Set Python 3.9 as the default
sudo alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 2
sudo alternatives --set python3 /usr/bin/python3.9

# Run the Ansible playbook
ansible-playbook -i ansible_inventory.ini bastion-prep.yml
