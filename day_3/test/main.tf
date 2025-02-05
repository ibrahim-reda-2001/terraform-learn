provider "aws" {
  region = "us-west-2"
}
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main"
  }
}
resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet1"
  }
}
resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet2"
  }
}
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "public-route-table"
  }
}
resource "aws_route_table_association" "public_association1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public-route-table.id
}
resource "aws_route_table_association" "public_association2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public-route-table.id
}


resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  tags = {
    Name = "private-subnet1"
  }
}
resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-west-2b"
  tags = {
    Name = "private-subnet2"
  }
}
resource "aws_nat_gateway" "nat1" {
  subnet_id     = aws_subnet.public1.id
  allocation_id = aws_eip.nat_eip1.id
  tags = {
    Name = "nat1"
  }
  depends_on = [aws_internet_gateway.gw]
}
resource "aws_eip" "nat_eip1" {
  domain = "vpc"
}
resource "aws_nat_gateway" "nat2" {
  subnet_id     = aws_subnet.public2.id
  allocation_id = aws_eip.nat_eip2.id
  tags = {
    Name = "nat2"
  }
  depends_on = [aws_internet_gateway.gw]
}
resource "aws_eip" "nat_eip2" {
  domain = "vpc"
}
resource "aws_route_table" "private-route-table1" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat1.id
  }
  tags = {
    Name = "private-route-table1"
  }
}
resource "aws_route_table_association" "private_association1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private-route-table1.id
}
resource "aws_route_table" "private-route-table2" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat2.id
  }
  tags = {
    Name = "private-route-table2"
  }
}
resource "aws_route_table_association" "private_association2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private-route-table2.id
}

resource "aws_security_group" "public_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public-sg"
  }
}

data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"] # Amazon-owned official AMIs

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"] # Amazon Linux 2
  }
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
resource "aws_instance" "public_instance1" {
  ami             = "ami-00c257e12d6828491"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.public1.id
  security_groups = [aws_security_group.public_sg.id]
  key_name        = aws_key_pair.deployer.key_name
  user_data       = <<-EOF
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
                          proxy_pass http://${aws_lb.private_lb.dns_name};
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

  tags = {
    Name = "public-instance1"
  }
  depends_on = [aws_lb.private_lb]
}

resource "aws_instance" "public_instance2" {
  ami             = "ami-00c257e12d6828491"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.public2.id
  security_groups = [aws_security_group.public_sg.id]
  key_name        = aws_key_pair.deployer.key_name
  user_data       = <<-EOF
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
                          proxy_pass http://${aws_lb.private_lb.dns_name};
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

  tags = {
    Name = "public-instance2"
  }
  depends_on = [aws_lb.private_lb]
}

resource "aws_instance" "private_instance1" {
  ami             = "ami-00c257e12d6828491"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.private1.id
  security_groups = [aws_security_group.public_sg.id]
  key_name        = aws_key_pair.deployer.key_name
 user_data       = <<-EOF
#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e

# Update package lists
sudo apt-get update -y

# Install Apache2
sudo apt-get install -y apache2

# Start and enable Apache service
sudo systemctl start apache2
sudo systemctl enable apache2

# Create a simple index.html file
sudo echo "<h1>Akhoyaa Dehaidh&Youssef</h1>" | sudo tee /var/www/html/index.html

# Restart Apache to apply changes
sudo systemctl restart apache2

# Log completion
echo "Apache installation and configuration complete" | sudo tee /var/log/user_data.log
EOF
  tags = {
    Name = "private-instance1"
  }
}

resource "aws_instance" "private_instance2" {
  ami             = "ami-00c257e12d6828491"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.private2.id
  security_groups = [aws_security_group.public_sg.id]
  key_name        = aws_key_pair.deployer.key_name
 user_data       = <<-EOF
#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e

# Update package lists
sudo apt-get update -y

# Install Apache2
sudo apt-get install -y apache2

# Start and enable Apache service
sudo systemctl start apache2
sudo systemctl enable apache2

# Create a simple index.html file
sudo echo "<h1>Akhoyaa Aliii</h1>" | sudo tee /var/www/html/index.html

# Restart Apache to apply changes
sudo systemctl restart apache2

# Log completion
echo "Apache installation and configuration complete" | sudo tee /var/log/user_data.log
EOF
  tags = {
    Name = "private-instance2"
  }
}


resource "aws_lb_target_group" "public_tg" {
  name        = "public-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"
}

resource "aws_lb_target_group_attachment" "public_instance1" {
  target_group_arn = aws_lb_target_group.public_tg.arn
  target_id        = aws_instance.public_instance1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "public_instance2" {
  target_group_arn = aws_lb_target_group.public_tg.arn
  target_id        = aws_instance.public_instance2.id
  port             = 80
}
resource "aws_lb" "public_lb" {
  name               = "public-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_sg.id]
  subnets            = [aws_subnet.public1.id, aws_subnet.public2.id]

  tags = {
    Name = "public-lb"
  }
}

resource "aws_lb_listener" "public_lb_listener" {
  load_balancer_arn = aws_lb.public_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public_tg.arn
  }
}
resource "aws_lb_target_group" "private_tg" {
  name        = "private-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"
}

resource "aws_lb_target_group_attachment" "private_instance1" {
  target_group_arn = aws_lb_target_group.private_tg.arn
  target_id        = aws_instance.private_instance1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "private_instance2" {
  target_group_arn = aws_lb_target_group.private_tg.arn
  target_id        = aws_instance.private_instance2.id
  port             = 80
}

resource "aws_lb" "private_lb" {
  name               = "private-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_sg.id]
  subnets            = [aws_subnet.private1.id, aws_subnet.private2.id]

  tags = {
    Name = "private-lb"
  }
}

resource "aws_lb_listener" "private_lb_listener" {
  load_balancer_arn = aws_lb.private_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.private_tg.arn
  }
}
resource "null_resource" "write_ips" {
  provisioner "local-exec" {
    command = <<-EOT
      echo "Public Instance 1 IP: ${aws_instance.public_instance1.public_ip}" > all-ips.txt
      echo "Public Instance 2 IP: ${aws_instance.public_instance2.public_ip}" >> all-ips.txt
      echo "Private Instance 1 IP: ${aws_instance.private_instance1.private_ip}" >> all-ips.txt
      echo "Private Instance 2 IP: ${aws_instance.private_instance2.private_ip}" >> all-ips.txt
    EOT
  }

  depends_on = [
    aws_instance.public_instance1,
    aws_instance.public_instance2,
    aws_instance.private_instance1,
    aws_instance.private_instance2
  ]
} 
resource "null_resource" "write_ips" {
  provisioner "local-exec" {
    command = <<-EOT
      echo "Public Instance 1 IP: ${aws_instance.public_instance1.public_ip}" > all-ips.txt
      echo "Public Instance 2 IP: ${aws_instance.public_instance2.public_ip}" >> all-ips.txt
      echo "Private Instance 1 IP: ${aws_instance.private_instance1.private_ip}" >> all-ips.txt
      echo "Private Instance 2 IP: ${aws_instance.private_instance2.private_ip}" >> all-ips.txt
    EOT
  }

  depends_on = [
    aws_instance.public_instance1,
    aws_instance.public_instance2,
    aws_instance.private_instance1,
    aws_instance.private_instance2
  ]
}