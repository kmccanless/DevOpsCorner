resource "aws_ecs_task_definition" "task_def" {
  container_definitions = file("${path.module}/files/task-def.json")
  family = "nginx"
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]
}i