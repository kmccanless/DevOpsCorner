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