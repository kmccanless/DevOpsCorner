provider "aws" {
  region = "us-east-2"
  profile = "default"
}
data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*"]
  }
}

data "http" "myip" {
  url = "http://icanhazip.com"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "DevOps-Corner"
  }
}
resource "aws_subnet" "public" {
  count = length(var.availibility_zones)
  cidr_block = element(var.cidr_blocks,count.index )
  vpc_id = aws_vpc.main.id
  availability_zone = element(var.availibility_zones,count.index )
  map_public_ip_on_launch = true
  tags = {
    Name = "public"
    Zone = var.availibility_zones[count.index]
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
  subnet_id = aws_subnet.public[0].id
}
resource "aws_subnet" "private" {
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-2b"
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "private"
  }
}
resource aws_key_pair "pub_key"{
  key_name = "devopscorner"
  public_key = file("./devopscorner.pub")
}
resource "aws_instance" "pub_bastion" {
  ami = data.aws_ami.amazon-linux-2.id
  associate_public_ip_address = true
  instance_type = "t4g.micro"
  key_name = aws_key_pair.pub_key.key_name
  vpc_security_group_ids = [aws_security_group.pub_sg.id]
  tags = {
    Name = "DevOpsCorner-Pub"
  }
  subnet_id = aws_subnet.public[0].id
}
resource "aws_instance" "app_server" {
  ami = data.aws_ami.amazon-linux-2.id
  associate_public_ip_address = true
  instance_type = "t4g.micro"
  key_name = aws_key_pair.pub_key.key_name
  vpc_security_group_ids = [aws_security_group.pub_sg.id]
  tags = {
    Name = "DevOpsCorner-private"
  }
  subnet_id = aws_subnet.private.id
}
resource "aws_security_group" "pub_sg" {
  name = "devopscorner-pub-sg"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "app_sg" {
  name = "devopscorner-pub-sg"
  vpc_id = aws_vpc.main.id
  ingress {
    security_groups = [aws_security_group.pub_sg.id]
    from_port = 22
    protocol = "tcp"
    to_port = 22
  }
  ingress {
    security_groups = [aws_security_group.pub_sg.id]
    from_port = 80
    protocol = "tcp"
    to_port = 80
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

