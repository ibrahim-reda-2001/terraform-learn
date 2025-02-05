provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr = "10.0.0.0/16"
  vpc_name = "main"

  public_subnets = [
    { cidr = "10.0.0.0/24", az = "us-east-1a" },
    { cidr = "10.0.2.0/24", az = "us-east-1b" }
  ]

  private_subnets = [
    { cidr = "10.0.1.0/24", az = "us-east-1a" },
    { cidr = "10.0.3.0/24", az = "us-east-1b" }
  ]
}

module "security_group" {
  source = "./modules/security_group"

  vpc_id = module.vpc.vpc_id
}

module "ec2" {
  source = "./modules/ec2"

  ami_id            = "ami-00c257e12d6828491"
  instance_type     = "t2.micro"
  public_subnet_ids = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  public_sg_id      = module.security_group.public_sg_id
  key_name          = aws_key_pair.deployer.key_name

  public_user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y nginx
              sudo cat <<EOT > /etc/nginx/nginx.conf
              worker_processes  1;
              events {
                  worker_connections  1024;
              }
              http {
                  server {
                      listen 80;
                      location / {
                          proxy_pass http://${module.lb.private_lb_dns_name};
                          proxy_set_header Host \$host;
                          proxy_set_header X-Real-IP \$remote_addr;
                          proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
                          proxy_set_header X-Forwarded-Proto \$scheme;
                      }
                  }
              }
              EOT
              sudo systemctl start nginx
              sudo systemctl enable nginx
              sudo systemctl restart nginx
              EOF

  private_user_data = <<-EOF
              #!/bin/bash
              set -e
              sudo apt-get update -y
              sudo apt-get install -y apache2
              sudo systemctl start apache2
              sudo systemctl enable apache2
              sudo echo "Hello from private instance" | sudo tee /var/www/html/index.html
              sudo systemctl restart apache2
              echo "Apache installation and configuration complete" | sudo tee /var/log/user_data.log
              EOF
}

module "lb" {
  source = "./modules/lb"

  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  public_sg_id       = module.security_group.public_sg_id
  public_instance_ids = module.ec2.public_instance_ids
  private_instance_ids = module.ec2.private_instance_ids
}

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
  file_permission = 0400
}

resource "null_resource" "write_ips" {
  provisioner "local-exec" {
    command = <<-EOT
      echo "Public Instance 1 IP: ${module.ec2.public_instance_ips[0]}" > all-ips.txt
      echo "Public Instance 2 IP: ${module.ec2.public_instance_ips[1]}" >> all-ips.txt
      echo "Private Instance 1 IP: ${module.ec2.private_instance_ips[0]}" >> all-ips.txt
      echo "Private Instance 2 IP: ${module.ec2.private_instance_ips[1]}" >> all-ips.txt
    EOT
  }

  depends_on = [
    module.ec2
  ]
}