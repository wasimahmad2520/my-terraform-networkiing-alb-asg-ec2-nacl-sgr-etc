/* References Variables */
variable "namespace" {
  type = string
}

variable "vpc" {
  type = any
}

variable key_name {
  type = string
}

variable "sg_pub_id" {
  type = any
}

variable "sg_priv_id" {
  type = any
}
/* Reference Varibles Ends */


/* AMI or OS Platform */
variable "os-platform" {
  description = "Ubuntu OS"
  default = "ami-0892d3c7ee96c0bf7"
  type = string
  
}

variable "instance_type" {
  default = "t2.micro"
}

variable "public_instance_user_data" {
  default = "./modules/ec2/user_data_web_server.sh"
  type = string
}


variable "public_instance_suffix" {
  default = "-EC2-PUBLIC"
}

variable "instance_user_name" {
  description = "target instance user name"
  default = "ubuntu"
  type = string
}

variable "key_placement_path" {
  description = "target instance key placement directory"
  default = "/home/ubuntu/"
  type = string
}

variable "db_server_private_ip" {
  description = "target instance default assigned private ip"
  default = "10.0.1.22"
  type = string
}

variable "db_server_user_data" {
  default = "./modules/ec2/user_data_db_server.sh"
  type = string
}

variable "db_server_suffix" {
  default = "-EC2-PRIVATE"
  type = string
}


