resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  tags = {
    Name = "DevOps-Corner"
  }
}
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "private" {
  count = var.az_count
  cidr_block = var.private_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "private"
  }
}

resource "aws_subnet" "public" {
  count = var.az_count
  cidr_block = var.public_cidr_blocks[count.index]
  vpc_id = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "public"
    Zone = data.aws_availability_zones.available.names[count.index]
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
  count = var.az_count
  route_table_id = aws_route_table.public_route_table.id
  subnet_id = aws_subnet.public[count.index].id
}