variable "cidr_block" {
    description = "A cidr block value formatted like: x.x.x.x/x"
    type = string
}

variable "cidr_blocks" {
    description = "A list of the cidr blocks to assign to subnets"
    type = list
}

variable "az_count" {
    description = "How many availability zones do you want to exist in?"
    type = number
    default = 1
}

variable "availability_zones" {
    description = "Availability zones that will be assigned to resources"
    type = list
    default = ["us-east-2a","us-east-2b"]
}