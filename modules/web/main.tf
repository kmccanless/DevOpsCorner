data "http" "myip" {
  url = "http://icanhazip.com"
}

resource "aws_launch_configuration" "pub_lc" {
  image_id = "ami-07a0844029df33d7d"
  instance_type = var.instance_type
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

resource "aws_autoscaling_notification" "asg_event" {
  group_names = [aws_autoscaling_group.pub_asg.name]
  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]
  topic_arn = aws_sns_topic.asg_sns_topic.arn
}
resource "aws_sns_topic" "asg_sns_topic" {
  name = "autoscaling-event"
}
resource "aws_sns_topic_subscription" "asg_subscription" {
  endpoint = "+11235551212"
  protocol = "sms"
  topic_arn = aws_sns_topic.asg_sns_topic.arn
}