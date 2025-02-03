resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = tls_private_key.example.public_key_openssh
}
resource "local_file" "private_key" {
  content  = tls_private_key.example.private_key_pem
  filename = "${path.module}/deployer-key.pem"
  file_permission = "0400"
}
output "private_key_path" {
  description = "Path to the private key file"
  value       = local_file.private_key.filename
}