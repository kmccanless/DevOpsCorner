data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = "../network/terraform.tfstate"
  }
}
data "terraform_remote_state" "cluster" {
  backend = "local"
  config = {
    path = "../cluster/terraform.tfstate"
  }
}
data "terraform_remote_state" "td" {
  backend = "local"
  config = {
    path = "../task/terraform.tfstate"
  }
}
data "terraform_remote_state" "alb" {
  backend = "local"
  config = {
    path = "../alb/terraform.tfstate"
  }
}
module "service" {
  source = "../../../modules/service"
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id
  service_subnets = data.terraform_remote_state.network.outputs.private_subnet_ids
  container_name = "nginx"
  container_port = 80
  td_arn = data.terraform_remote_state.td.outputs.td_arn
  cluster_id = data.terraform_remote_state.cluster.outputs.cluster_id
  lb_target_group_arn = data.terraform_remote_state.alb.outputs.lb_target_group_arn
  lb_sg_id = data.terraform_remote_state.alb.outputs.lb_sg_id
  desired_count = 1
}