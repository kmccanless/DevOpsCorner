resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  tags = {
    Name = "DevOps-Corner"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public" {
  count = var.az_count
  cidr_block = var.cidr_blocks[count.index]
  vpc_id = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "public"
    Zone = data.aws_availability_zones.available.names[count.index]
  }
}