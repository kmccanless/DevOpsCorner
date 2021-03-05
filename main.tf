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
resource aws_key_pair "pub_key"{
  key_name = "devopscorner"
  public_key = file("./devopscorner.pub")
}
resource "aws_instance" "ansible" {
  ami = "ami-09246ddb00c7c4fef"
  associate_public_ip_address = true
  instance_type = "t2.micro"
  key_name = aws_key_pair.pub_key.key_name
  vpc_security_group_ids = [
    aws_security_group.pub_sg.id]
  tags = {
    Name = "DevOpsCorner-Ansible"
  }
  subnet_id = aws_subnet.public.id

  connection {
    host = self.public_ip
    type = "ssh"
    user = "ec2-user"
    private_key = file("devopscorner")
  }

  provisioner "file" {
    source = "./ansible/play.yml"
    destination = "/tmp/play.yml"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo amazon-linux-extras install ansible2 -y",
      "ansible-playbook /tmp/play.yml"
    ]
  }
  provisioner "file" {
    source = "./ansible/index.html"
    destination = "/tmp/index.html"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/index.html /var/www/html/index.html"
    ]
  }
}

//resource "aws_instance" "user_data" {
//  ami = "ami-09246ddb00c7c4fef"
//  associate_public_ip_address = true
//  instance_type = "t2.micro"
//  key_name = aws_key_pair.pub_key.key_name
//  vpc_security_group_ids = [aws_security_group.pub_sg.id]
//  tags = {
//    Name = "DevOpsCorner-User-Data"
//  }
//  subnet_id = aws_subnet.public.id
//  user_data = <<EOF
//    #!/bin/bash
//    yum install httpd -y
//    systemctl start httpd
//    echo "<h1>Let there be provisioning</h1>" | sudo tee /var/www/html/index.html
//  EOF
//
//}
resource "aws_security_group" "pub_sg" {
  name = "devopscorner-pub-sg"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

