variable "namespace" {
  type = string
}




variable "vpc_cidr" {
  default = "10.0.0.0/16"
  type = string
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}


variable "public_subnets" {
  type    = list(string)
  default =  ["10.0.101.0/24", "10.0.102.0/24"]
}


variable "vpc_create_database_subnet_group" {
  default = true
  type = bool
}


variable "vpc_enable_gateway" {
  default = true
  type = bool
}

variable "vpc_single_nat_gateway" {
  default = true
  type = bool
}

