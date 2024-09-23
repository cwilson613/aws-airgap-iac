# Terraform Configuration for Confluent Deployment

## Overview

This Terraform configuration provisions AWS infrastructure to host Confluent Platform on EC2 instances within a private network, disconnected from the internet.

## Prerequisites

- Terraform >= 0.12
- AWS CLI configured with appropriate credentials

## Instructions

1. **Initialize Terraform**

   ```bash
   terraform init