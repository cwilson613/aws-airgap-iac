output "private_ips" {
  description = "Private IPs of the Confluent instances"
  value       = aws_instance.confluent_instances[*].private_ip
}

output "bastion_public_ip" {
  description = "Public IP of the Bastion node"
  value       = aws_instance.bastion_instance.public_ip
}

output "ssh_command" {
  description = "Simple prepopulated command for speed"
  value       = "ssh -i ./terraform/confluent-ec2-key.pem ec2-user@${aws_instance.bastion_instance.public_ip}"
}

