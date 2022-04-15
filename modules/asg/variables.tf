/* Reference Varibles  */

variable "namespace" {
  type = string
}

variable "vpc" {
  type = any
}
/* Key name */
variable key_name {
  type = string
}

/* for creating AMI */
variable "demosg1" {
  type = any
}


/* Web Server AMI Name */
variable "my_ami" {
  type = any
}

/* ELB */
variable "alb" {
  type = any
}

variable "lb_target" {
  type = any
}

/* Reference Varibles ends */


/* Launch Config Varibles */
variable "lc_prefix" {
  default = "LC-Web-"
}

variable "lc_instance_type" {
  default = "t2.micro"
}

variable "lc_user_data" {
  default = "./modules/ec2/user_data_web_server.sh"
  type=string
}

/* launch config ends */


/* auto scalling group variables */

variable "asg_min_size" {
  default = 2
}

variable "asg_max_size" {
  default = 6
}

variable "asg_desired_size" {
  default = 3
}

variable "asg_health_check_type" {
  default = "ELB"
  type = string
}

variable "asg_instance_name" {
  default = "ASG-Web-Server"
}






/* variable "sg_pub_id" {
  type = any
}

variable "sg_priv_id" {
  type = any
} */


/* variable "os-platform" {
  description = "Ubuntu OS"
  default = "ami-0892d3c7ee96c0bf7"
  type = string
  
} */
