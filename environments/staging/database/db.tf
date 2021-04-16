data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = "../network/terraform.tfstate"
  }
}
data "terraform_remote_state" "app_server" {
  backend = "local"
  config = {
    path = "../web/terraform.tfstate"
  }
}
module "rds_instance" {
  source = "cloudposse/rds/aws"
  namespace                   = "eg"
  stage                       = "staging"
  name                        = "devops_corner"
  security_group_ids          = [data.terraform_remote_state.app_server.outputs.public_sg]
  database_name               = "devops_corner"
  database_user               = "admin"
  database_password           = "devops-password"
  database_port               = 3306
  multi_az                    = true
  storage_type                = "gp2"
  allocated_storage           = 100
  storage_encrypted           = true
  engine                      = "mysql"
  engine_version              = "5.7.17"
  major_engine_version        = "5.7"
  instance_class              = "db.t2.small"
  db_parameter_group          = "mysql5.7"
  publicly_accessible         = false
  subnet_ids                  = data.terraform_remote_state.network.outputs.private_subnet_ids
  vpc_id                      = data.terraform_remote_state.network.outputs.vpc_id
  auto_minor_version_upgrade  = true
  allow_major_version_upgrade = false
  apply_immediately           = false
  maintenance_window          = "Mon:03:00-Mon:04:00"
  skip_final_snapshot         = true
  copy_tags_to_snapshot       = true
  backup_retention_period     = 7
  backup_window               = "22:00-03:00"
}