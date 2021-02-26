variable "availibility_zones" {
  type = list(string)
  default = ["us-east-2a","us-east-2b"]
}
variable "cidr_blocks" {
  type = list(string)
  default = ["10.0.1.0/24","10.0.2.0/24"]
}