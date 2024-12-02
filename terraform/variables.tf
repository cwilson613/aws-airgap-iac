variable "aws_region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "us-east-1"
}

variable "oracle_ami_id" {
  description = "AMI ID for Oracle Linux 8"
  type        = string
  default     = "ami-087d72c9f3d1fd5be" # Oracle Linux AMI
}

variable "is_air_gapped" {
  description = "Toggle for air-gapped environment. Set to true for air-gapped, false for internet access."
  type        = bool
  default     = true
}

variable "bastion_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.large"
}

variable "ksql_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "m5.xlarge"
}

variable "control_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "m5.2xlarge"
}

variable "kafka_broker_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "m5.xlarge"
}

variable "zookeeper_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "m5.8xlarge"
}
variable "kafka_controller_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "m5.8xlarge"
}

variable "schema_registry_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "m5.4xlarge"
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

variable "key_pair_name" {
  description = "Name of the existing AWS Key Pair to use for EC2 instances"
  type        = string
  default     = "cog-team"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block for SSH access"
  type        = string
  default     = "0.0.0.0/0"
}

variable "user" {
  description = "User for naming differentiation"
  type        = string
}

variable "bastion_instance_count" {
  description = "Number of bastion instances to create"
  type        = number
  default     = 1
}

variable "kafka_controller_instance_count" {
  description = "Number of Kafka Controller instances to create"
  type        = number
  default     = 0
}

variable "zookeeper_instance_count" {
  description = "Number of zookeeper instances to create"
  type        = number
  default     = 3
}

variable "kafka_broker_instance_count" {
  description = "Number of Kafka Broker instances to create"
  type        = number
  default     = 3
}

variable "ksql_instance_count" {
  description = "Number of ksqlDB instances to create"
  type        = number
  default     = 1
}

variable "control_center_instance_count" {
  description = "Number of Control Center instances to create"
  type        = number
  default     = 1
}

variable "schema_registry_instance_count" {
  description = "Number of Schema Registry instances to create"
  type        = number
  default     = 1
}