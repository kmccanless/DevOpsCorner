output "vpc_id" {
  value = module.vpc.vpc_id
}
output "public_subnet_ids" {
  value = module.vpc.public_subnets.*.id
}
output "private_subnet_ids" {
  value = module.vpc.private_subnets.*.id
}