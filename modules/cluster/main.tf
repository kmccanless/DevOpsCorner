resource "aws_ecs_cluster" "cluster" {
  name = "devOps-corner"
  capacity_providers = ["FARGATE"]
}