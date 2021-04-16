variable "cidr_block" {
    description = "A cidr block value formatted like: x.x.x.x/x"
    type = string
}

variable "public_cidr_blocks" {
    description = "A list of the cidr blocks to assign to subnets"
    type = list
}
variable "private_cidr_blocks" {
    description = "A list of the cidr blocks to assign to subnets"
    type = list
}
