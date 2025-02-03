resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public-route-table"
  }
}
resource "aws_route_table_association" "public1_association" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public_route_table.id
}
resource "aws_route_table_association" "public2_association" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public_route_table.id
}
resource "aws_route_table" "private_route_table1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw1.id
  }

  tags = {
    Name = "private-route-table1"
  }
}
resource "aws_route_table_association" "private1_association" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private_route_table1.id
}

resource "aws_route_table" "private_route_table2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw2.id
  }

  tags = {
    Name = "private-route-table2"
  }
}

resource "aws_route_table_association" "private2_association" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private_route_table2.id
}