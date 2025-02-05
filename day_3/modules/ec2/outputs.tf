output "public_instance_ids" {
  value = aws_instance.public[*].id
}

output "private_instance_ids" {
  value = aws_instance.private[*].id
}

output "public_instance_ips" {
  value = aws_instance.public[*].public_ip
}

output "private_instance_ips" {
  value = aws_instance.private[*].private_ip
}