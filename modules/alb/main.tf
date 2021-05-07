resource "aws_lb" "lb" {
  name                             = "dev-ops-corner-lb"
  internal                         = false
  load_balancer_type               = "application"
  subnets                          = var.load_balancer_subnets
  idle_timeout                     = 120
  enable_deletion_protection       = false
  enable_http2                     = false
  ip_address_type                  = "ipv4"
  security_groups                  = [aws_security_group.lb_access_sg.id]
}

resource "aws_security_group" "lb_access_sg" {
  name        = "devops-corner-lb-access-sg"
  description = "Controls access to the Load Balancer"
  vpc_id      = var.vpc_id
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "devops-corner-lb-access-sg"
  }
}

resource "aws_security_group_rule" "ingress_through_http" {
  security_group_id = aws_security_group.lb_access_sg.id
  description = ""
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_lb_target_group" "lb_tg" {
  name                          = "devops-corner-lb-tg"
  port                          = 80
  protocol                      = "HTTP"
  vpc_id                        = var.vpc_id
  health_check {
    enabled = true
  }
  target_type = "ip"
  tags = {
    Name = "devops-corner-lb-blue-tg"
  }
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [ aws_lb.lb ]
}

resource "aws_lb_listener" "lb_https_listeners" {
  load_balancer_arn = aws_lb.lb.arn
  port = 80
  protocol = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.lb_tg.arn
    type = "forward"
  }

}