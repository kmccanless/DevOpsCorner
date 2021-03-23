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

module "vpc" {
  source = "./modules/vpc"
  az_count = 2
  cidr_block  = "10.0.0.0/16"
  cidr_blocks = ["10.0.1.0/24","10.0.2.0/24"]
}

resource "aws_internet_gateway" "gw" {
  vpc_id = module.vpc.vpc_id
}
resource "aws_route_table" "public_route_table" {
  vpc_id = module.vpc.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}
resource "aws_route_table_association" "rt_association" {
  count = length(var.availibility_zones)
  route_table_id = aws_route_table.public_route_table.id
  subnet_id = module.vpc.public_subnets[count.index].id
}
resource "aws_subnet" "private" {
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-2b"
  vpc_id = module.vpc.vpc_id
  tags = {
    Name = "private"
  }
}
resource aws_key_pair "pub_key"{
  key_name = "devopscorner"
  public_key = file("./devopscorner.pub")
}
//resource "aws_instance" "pub_web" {
//  count = length(var.availibility_zones)
//  ami = "ami-07a0844029df33d7d"
//  associate_public_ip_address = true
//  instance_type = "t2.micro"
//  key_name = aws_key_pair.pub_key.key_name
//  vpc_security_group_ids = [aws_security_group.pub_sg.id]
//  tags = {
//    Name = "DevOpsCorner-Pub"
//  }
//  subnet_id = module.vpc.public_subnet_ids[count.index]
//}
//resource "aws_instance" "db_server" {
//  ami = "ami-07a0844029df33d7d"
//  associate_public_ip_address = false
//  instance_type = "t2.micro"
//  key_name = aws_key_pair.pub_key.key_name
//  vpc_security_group_ids = [aws_security_group.db_sg.id]
//  tags = {
//    Name = "DevOpsCorner-app-server"
//  }
//  subnet_id = aws_subnet.private.id
//}
resource "aws_launch_configuration" "pub_lc" {
  image_id = "ami-07a0844029df33d7d"
  instance_type = "t2.micro"
  key_name = aws_key_pair.pub_key.key_name
  security_groups = [aws_security_group.pub_sg.id]
}
resource "aws_autoscaling_group" "pub_asg" {
  max_size = 2
  min_size = 2
  desired_capacity = 2
  launch_configuration = aws_launch_configuration.pub_lc.name
  vpc_zone_identifier = module.vpc.public_subnets.*.id
}

resource "aws_security_group" "pub_sg" {
  name = "devopscorner-pub-sg"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }
  ingress {
    from_port = 443
    protocol = "tcp"
    to_port = 443
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db_sg" {
  name = "devopscorner-app-sg"
  vpc_id = module.vpc.vpc_id
  ingress {
    security_groups = [aws_security_group.pub_sg.id]
    from_port = 3306
    protocol = "tcp"
    to_port = 3306
  }
  ingress {
    security_groups = [aws_security_group.pub_sg.id]
    from_port = 22
    protocol = "tcp"
    to_port = 22
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

