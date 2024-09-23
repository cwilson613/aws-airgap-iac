# Confluent Deployment Infrastructure on AWS EC2 Instances

## Overview

This project automates the provisioning of AWS infrastructure required for deploying Confluent Platform on EC2 instances within a private, internet-disconnected environment (air-gapped simulation). The deployment of Confluent using Ansible will be handled externally.

## Prerequisites

- Terraform >= 0.12
- AWS CLI configured with appropriate credentials
- Python 3
- Just (optional, for task automation)
- Make (optional, for task automation)

## Project Structure

- `terraform/`: Contains Terraform configuration files to provision AWS resources.
- `scripts/`: Contains helper scripts.
- `Makefile`: Automates Terraform commands.
- `Justfile`: Automates Terraform commands.
- `README.md`: Project documentation.

## Setup Instructions

1. **Clone the Repository**

   ```bash
   git clone https://github.com/your-repo/confluent-aws-infrastructure.git
   cd confluent-aws-infrastructure
   ```

2. **Set up your AWS credentials**

    ```bash
    export AWS_ACCESS_KEY_ID=AKIXXXXXXXXXXXXXXXXX
    export AWS_SECRET_ACCESS_KEY=YTRvdGdpaGF3Z3BhaXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    ```

3. **Run `make` or `just` commands**

    ```
    make init
    make apply
    ```

    ```
    just init
    just apply
    ```

4. **Use outputs to begin confluent installation**

    The output from Terraform will include info like the bastion's public IP and the private IPs of the nodes.

    This output can be regenerated quickly using

    ```
    make output
    ```

    Example:
    ```
    ❯ make output
    terraform -chdir=./terraform output
    bastion_public_ip = "44.XXX.XXX.XXX"
    private_ips = [
    "10.0.1.178",
    "10.0.1.128",
    "10.0.1.50",
    ]
    ssh_command = "ssh -i ./terraform/confluent-ec2-key.pem ec2-user@44.XXX.XXX.XXX"
    ```

The private key should also be present on the bastion machine.

SSH is only accepted to the nodes if it's coming from the public subnet, so use the bastion as an internet-connected jumpbox.