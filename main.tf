
provider "aws" {
  region = "us-east-1"
  access_key = "AKIA5CBGTGSPWMQHAX2Y"
  secret_key = "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"

}
variable "vpc_cider_block" {
  type = string
}
variable "subnet_cider_block" {
  type = string
}
variable "avail_zone" {
  type = string
}
variable "env_perfix" {
  type = string
}
variable "myip" {
  type = string
}
variable "instance_type" {
    type = string
  
}
variable "mypublic-key" {
  type = string
}
resource "aws_vpc" "myvpc-vpc" {
  cidr_block = var.vpc_cider_block
  tags = {
    Name = "${var.env_perfix}-vpc"
  }

}


resource "aws_subnet" "myapp-subnet-1" {
  vpc_id            = aws_vpc.myvpc-vpc.id
  cidr_block        = var.subnet_cider_block
  availability_zone = var.avail_zone
  tags = {
    Name = "${var.env_perfix}-subnet"
  }
}
resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.myvpc-vpc.id
  tags = {
    Name = "${var.env_perfix}-igw "
  }
}
/******** configure default route table *************/
//no need for route table association
resource "aws_default_route_table" "myapp-route-table" {
  default_route_table_id = aws_vpc.myvpc-vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = {
    Name = "${var.env_perfix}-default-rtb"
  }
}




/*
resource "aws_route_table" "myapp-route-table" {
  vpc_id = aws_vpc.myvpc-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id =aws_internet_gateway.myapp-igw.id 
  }
  tags = {
    Name="${var.env_perfix}-rtb"
  }
}  

resource "aws_route_table_association" "a-rtb-subnet" {
  subnet_id =aws_subnet.myapp-subnet-1.id
  route_table_id = aws_route_table.myapp-route-table.id   
}*/
/***** configure default security group ***********/
resource "aws_default_security_group" "myapp-default-sg" {

  vpc_id = aws_vpc.myvpc-vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.myip]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
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
    Name = "${var.env_perfix}-defaultsg"
  }
}
/*resource "aws_security_group" "myapp-sg" {
  name = "myapp-sg"
  vpc_id = aws_vpc.myvpc-vpc.id
  ingress {
            from_port = 22
            to_port = 22
            protocol = "tcp"
            cidr_blocks = [var.myip]
  }
  ingress {
            from_port = 8080
            to_port = 8080
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
   tags = {
    Name="${var.env_perfix}-sg"
  }
}*/
/* dynamic aws iam */
data "aws_ami" "latest-amazon-linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.6.20241010.0-kernel-6.1-x86_64"]
  }
}
output "aws_ami_id" {
  value = data.aws_ami.latest-amazon-linux.id
}

resource "aws_key_pair" "ssh-key" {
  key_name = "server-key-pair"
  public_key = var.mypublic-key
}
resource "aws_instance" "myapp-server" {
  ami = data.aws_ami.latest-amazon-linux.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids = [aws_default_security_group.myapp-default-sg.id]
  availability_zone = var.avail_zone
  associate_public_ip_address = true 
  key_name = aws_key_pair.ssh-key.key_name
  //key_name = "server-key"//this key i created from gui in aws 
  tags = {
    Name="${var.env_perfix}-server"
  }
user_data = file("entry.sh")
}
output "publicip" {
  value =aws_instance.myapp-server.public_ip
}