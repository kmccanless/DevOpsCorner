resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  tags = {
    Name = "DevOps-Corner"
  }
}

resource "aws_subnet" "public" {
  count = var.az_count
  cidr_block = var.cidr_blocks[count.index]
  vpc_id = aws_vpc.main.id
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "public"
    Zone = var.availability_zones[count.index]
  }
}