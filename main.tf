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




