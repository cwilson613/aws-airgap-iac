output "private_ips" {
  description = "Private IPs of the Confluent instances"
  value = concat(
    aws_instance.confluent_instances[*].private_ip,
    [aws_instance.control_node.private_ip]
  )
}

output "control_node_private_ip" {
  description = "Private IP of the Control Node"
  value       = aws_instance.control_node.private_ip
}

output "distro_server_public_ip" {
  description = "Public IP of the Bastion Node"
  value       = aws_instance.distro_server.public_ip
}

output "ssh_command" {
  description = "Simple prepopulated command for speed"
  value       = "ssh -i ~/.ssh/cog-team.pem ec2-user@${aws_instance.distro_server.public_ip}"
}

