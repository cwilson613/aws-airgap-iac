# Justfile for automating tasks

set shell := ["bash", "-cu"]

# Set the working directory for all commands
set working-directory := "terraform"

# Default recipe
default:
	output

# Initialize with upgrade
init-upgrade:
	terraform init -upgrade

# Initialize without upgrade
init:
	terraform init

# Plan the Terraform changes
plan:
	terraform plan

# Apply the Terraform changes
apply:
	terraform apply

# Show the Terraform output
output:
	terraform output

# Destroy the Terraform infrastructure
down:
	terraform destroy -auto-approve

# Configure Ansible inventory using Terraform outputs
configure_inventory:
	@echo "Configuring Ansible inventory with Terraform outputs..."
	@terraform -chdir=terraform output -json > terraform/outputs.json
	@python scripts/generate_inventory.py