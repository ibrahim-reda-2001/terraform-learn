resource "aws_eip" "nat_eip1" {
  domain = "vpc"
}
resource "aws_nat_gateway" "nat_gw1" {
  allocation_id = aws_eip.nat_eip1.id
  subnet_id     = aws_subnet.public1.id

  tags = {
    Name = "nat-gw1"
  }
}
resource "aws_eip" "nat_eip2" {
  vpc = true
}
resource "aws_nat_gateway" "nat_gw2" {
  allocation_id = aws_eip.nat_eip2.id
  subnet_id     = aws_subnet.public2.id

  tags = {
    Name = "nat-gw2"
  }
}