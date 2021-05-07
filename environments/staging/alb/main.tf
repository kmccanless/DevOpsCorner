data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = "../network/terraform.tfstate"
  }
}

module "alb" {
  source = "../../../modules/alb"
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id
  load_balancer_subnets = data.terraform_remote_state.network.outputs.public_subnet_ids
}