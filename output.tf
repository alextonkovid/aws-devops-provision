output "private_instance_ip" {
  value = data.aws_instance.k3s_instance.private_ip
}

output "nat_instance_ip" {
  value = data.aws_eip.nat_eip.public_ip
}

