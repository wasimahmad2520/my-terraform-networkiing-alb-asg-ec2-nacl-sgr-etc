

/* Reference Variables */
variable "vpc" {
  type = any
}
variable "namespace" {
  type = string
}

/* ends */

variable "nacl_tag" {
  default = "nacl-terraform"
  type = string
}

