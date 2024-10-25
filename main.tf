
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
}
