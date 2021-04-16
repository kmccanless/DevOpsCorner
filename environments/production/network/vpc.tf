module "vpc" {
  source = "../../../modules/vpc"
  az_count = 2
  cidr_block  = "10.5.0.0/16"
  public_cidr_blocks = ["10.5.1.0/24","10.5.2.0/24"]
  private_cidr_blocks = ["10.5.3.0/24","10.5.4.0/24"]
}

output "public_subnets" {
  "value" = module.vpc.output.public_subnets
}