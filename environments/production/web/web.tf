data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../network/terraform.tfstate"
  }
}

module "web" {
  path = "../../../web"
  public_subnets = data.terraform_remote_state.vpc.output.public_subnets
}

