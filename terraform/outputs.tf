output "control_center_ips" {
  description = "Private IPs of the Control Center Nodes"
  value       = aws_instance.control_center[*].private_ip
}

output "ksql_ips" {
  description = "Private IPs of the KSQL Nodes"
  value       = aws_instance.ksql[*].private_ip
}

output "kafka_broker_ips" {
  description = "Private IPs of the Kafka Broker Nodes"
  value       = aws_instance.kafka_broker[*].private_ip
}

output "kafka_controller_ips" {
  description = "Private IPs of the Kafka Controller Nodes"
  value       = aws_instance.kafka_controller[*].private_ip
}

output "zookeeper_ips" {
  description = "Private IPs of the zookeeper Nodes"
  value       = aws_instance.zookeeper[*].private_ip
}

output "schema_registry_ips" {
  description = "Private IPs of the Schema Registry Nodes"
  value       = aws_instance.schema_registry[*].private_ip
}

output "bastion_public_ip" {
  description = "Public IP of the Bastion Node"
  value       = aws_instance.bastion[0].public_ip
}

output "ssh_command" {
  description = "Simple prepopulated command for speed"
  value       = "ssh -i ~/.ssh/cog-team.pem ec2-user@${aws_instance.bastion[0].public_ip}"
}

# Outputs for Ansible Inventory
output "ansible_inventory" {
  value = {
    kafka_controller = {
      hosts = aws_instance.kafka_controller[*].private_dns
    }
    zookeeper = {
      hosts = aws_instance.zookeeper[*].private_dns
    }
    kafka_broker = {
      hosts = aws_instance.kafka_broker[*].private_dns
    }
    control_center = {
      hosts = aws_instance.control_center[*].private_dns
    }
    schema_registry = {
      hosts = aws_instance.schema_registry[*].private_dns
    }
    ksql = {
      hosts = aws_instance.ksql[*].private_dns
    }
  }
}

# Print the outputs in the desired format
output "formatted_inventory" {
  value = templatefile("${path.module}/inventory.tpl", {
    kafka_controller_dns = aws_instance.kafka_controller[*].private_dns
    zookeeper_dns        = aws_instance.zookeeper[*].private_dns
    kafka_broker_dns     = aws_instance.kafka_broker[*].private_dns
    control_center_dns   = aws_instance.control_center[*].private_dns
    schema_registry_dns  = aws_instance.schema_registry[*].private_dns
    ksql_dns             = aws_instance.ksql[*].private_dns
  })
}
