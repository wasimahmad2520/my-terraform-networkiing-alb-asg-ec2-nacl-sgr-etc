/* Reference Variables */
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
variable "ec2_instance" {
  type = any
}


/* Web Server AMI Name */
variable "ami_name" {
  default = "Web-Server-AMI"
}

/* References Variables Ends */






/* ALB Prefix */
variable "prefix" {
  default = "Web-ELB-"
  type = string
}


variable "load_balancer_type" {
  default = "application"
  type = string
}




variable "alb_tag" {
  default = "ALB"
  type = string
}

/* Health Check Variables */

variable "hc_interval" {
  default = 10
  type = any
}


variable "hc_healthy_threshold" {
  default = 2
  type = any
}


variable "hc_unhealthy_threshold" {
  default = 2
  type = any
}


variable "hc_timeout" {
  default = 3
  type = any
}


variable "hc_path" {
  default = "/"
  type = string
}


variable "hc_port" {
  default = 80
  type = any
}



variable "hc_matcher" {
  default = "200"
  type = string
}
/* health check ends */


/* target group varibales */
variable "target_group_tag" {
  default = "ALB-Target-GR"
  type = any
}

variable "target_group_prefix" {
  default = "LB-TG-"
  type = string
}


variable "target_group_protocol" {
  default = "HTTP"
  type = string
}





/* variable "sg_pub_id" {
  type = any
}

variable "sg_priv_id" {
  type = any
} */


variable "os-platform" {
  description = "Ubuntu OS"
  default = "ami-0892d3c7ee96c0bf7"
  type = string
  
}
