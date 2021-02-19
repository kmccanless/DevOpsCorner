provider "aws" {
  region = "us-east-2"
  profile = "default"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "DevOps-Corner"
  }
}
resource "aws_subnet" "public" {
  cidr_block = "10.0.0.0/24"
  vpc_id = aws_vpc.main.id
  map_public_ip_on_launch = true
  tags = {
    Name = "public"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}
resource "aws_route_table_association" "rt_association" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id = aws_subnet.public.id
}
resource "aws_subnet" "private" {
  cidr_block = "10.0.1.0/24"
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "private"
  }
}