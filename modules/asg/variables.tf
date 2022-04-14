variable "namespace" {
  type = string
}

variable "vpc" {
  type = any
}

variable key_name {
  type = string
}

/* for creating AMI */
variable "security_group_name" {
  type = any
}


/* Web Server AMI Name */
variable "ami_name" {
  type = any
}

/* ELB */
variable "alb" {
  type = any
}


variable "sg_pub_id" {
  type = any
}

variable "sg_priv_id" {
  type = any
}


variable "os-platform" {
  description = "Ubuntu OS"
  default = "ami-0892d3c7ee96c0bf7"
  type = string
  
}
