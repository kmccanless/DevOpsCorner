resource "aws_ecs_service" "service" {
  name                               = "devops-corner-service"
  cluster                            = var.cluster_id
  desired_count                      = var.desired_count
  health_check_grace_period_seconds  = 30
  launch_type                        = "FARGATE"
  force_new_deployment               = true
  platform_version                   = "1.4.0"
  load_balancer {
    target_group_arn = var.lb_target_group_arn
    container_name = var.container_name
    container_port = var.container_port
  }
  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks_sg.id]
    subnets          = var.service_subnets
    assign_public_ip = true
  }
  #ignore changes in the TB from CircleCI deployment
  lifecycle {
    ignore_changes = [task_definition]
  }
  deployment_controller {
    type = "ECS"
  }

  task_definition = var.td_arn
  propagate_tags = "SERVICE"
  tags = {
    Name = "devops-corner"
  }
  depends_on = [var.lb_target_group_arn]
}

resource "aws_security_group" "ecs_tasks_sg" {
  name        = "devops-corner-ecs-tasks-sg"
  description = "Allow inbound access from the LB only"
  vpc_id      = var.vpc_id
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = var.container_port
    protocol = "tcp"
    to_port = var.container_port
    security_groups = [var.lb_sg_id]
  }
  tags = {
    Name = "devops-corner-ecs-tasks-sg"
  }
}