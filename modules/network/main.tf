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
  count = length(var.private_cidr_blocks)
  cidr_block = var.private_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "private"
  }
}
resource "aws_subnet" "public" {
  count = length(var.public_cidr_blocks)
  cidr_block = var.public_cidr_blocks[count.index]
  vpc_id = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "public"
    Zone = data.aws_availability_zones.available.names[count.index]
  }
}
resource "aws_eip" "nat_eip" {
  count = length(aws_subnet.public)
  vpc   = true
}
resource "aws_nat_gateway" "nat_gw" {
  count         = length(aws_subnet.public)
  allocation_id = element(aws_eip.nat_eip.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
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
  count = length(var.public_cidr_blocks)
  route_table_id = aws_route_table.public_route_table.id
  subnet_id = aws_subnet.public[count.index].id
}
resource "aws_route_table" "private_subnets_route_table" {
  count  = length(var.private_cidr_blocks)
  vpc_id = aws_vpc.main.id
}
# Private route to access internet
resource "aws_route" "private_internet_route" {
  count      = length(var.private_cidr_blocks)
  depends_on = [
    aws_internet_gateway.gw,
    aws_route_table.private_subnets_route_table,
  ]
  route_table_id         = element(aws_route_table.private_subnets_route_table.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat_gw.*.id, count.index)
}
# Association of Route Table to Subnets
resource "aws_route_table_association" "private_internet_route_table_associations" {
  count     = length(var.private_cidr_blocks)
  subnet_id = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(
  aws_route_table.private_subnets_route_table.*.id,
  count.index,
  )
}