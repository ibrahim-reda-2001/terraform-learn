
provider "aws" {
  region     = "us-east-1"
  
}
variable "vpc_cider_block" {
    type = string
}
variable "subnet_cider_block" {
  type=string
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
resource "aws_vpc" "myvpc-vpc" {
  cidr_block = var.vpc_cider_block
  tags = {
    Name = "${var.env_perfix}-vpc"
  }

}
  

resource"aws_subnet" "myapp-subnet-1" {
  vpc_id = aws_vpc.myvpc-vpc.id
  cidr_block = var.subnet_cider_block
  availability_zone = var.avail_zone
  tags = {
    Name="${var.env_perfix}-subnet"
  }
} 
resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = aws_vpc.myvpc-vpc.id
  tags = {
    Name="${var.env_perfix}-igw "
  }
} 
/******** configure default route table *************/
//no need for route table association
resource "aws_default_route_table" "myapp-route-table" {
  default_route_table_id= aws_vpc.myvpc-vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id =aws_internet_gateway.myapp-igw.id 
  }
  tags = {
    Name="${var.env_perfix}-default-rtb"
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
    Name="${var.env_perfix}-defaultsg"
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
