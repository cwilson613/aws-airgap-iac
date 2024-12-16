aws_region                       = "us-east-1"

oracle_ami_id                    = "ami-087d72c9f3d1fd5be"

is_air_gapped                    = false
associate_public_ip              = false

repo_url                         = "git@github.com:cwilson613/confluent-airgap-bundler.git"

bastion_instance_type            = "t2.large"
ksql_instance_type               = "m5.xlarge"
control_instance_type            = "m5.2xlarge"
kafka_broker_instance_type       = "m5.xlarge"
zookeeper_instance_type          = "m5.8xlarge"
kafka_controller_instance_type   = "m5.8xlarge"
schema_registry_instance_type    = "m5.4xlarge"

vpc_cidr                         = "10.0.0.0/16"
private_subnet_cidr              = "10.0.1.0/24"
public_subnet_cidr               = "10.0.2.0/24"

key_pair_name                    = "cog-team"
allowed_ssh_cidr                 = "0.0.0.0/0"

# If you want terraform to prompt for user then comment this line out
user                             = "jwu"

bastion_instance_count           = 1
kafka_controller_instance_count  = 0
zookeeper_instance_count         = 3
kafka_broker_instance_count      = 3
ksql_instance_count              = 1
control_center_instance_count    = 1
schema_registry_instance_count   = 1
