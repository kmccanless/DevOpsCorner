data "http" "myip" {
  url = "http://icanhazip.com"
}

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
  vpc_zone_identifier = var.public_subnet_ids
}
resource aws_key_pair "pub_key" {
  key_name = "devopscorner"
  public_key = file("../../../assets/devopscorner.pub")
}
resource "aws_security_group" "pub_sg" {
  name = "devopscorner-pub-sg"
  vpc_id = var.vpc_id
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