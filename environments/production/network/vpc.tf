module "vpc" {
  source = "./modules/vpc"
  az_count = 2
  cidr_block  = "10.0.0.0/16"
  cidr_blocks = ["10.0.1.0/24","10.0.2.0/24"]
}