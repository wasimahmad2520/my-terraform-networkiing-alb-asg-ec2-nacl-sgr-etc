variable "namespace" {
  description = "The project namespace to use for unique resource naming"
  default     = "terraform-assignment"
  type        = string
}

variable "region" {
  description = "AWS region"
  default     = "us-west-2"
  type        = string
}

/* variable "main_vpc_id" {
  description = "VPC ID"
  type        = string
} */



/* https://www.ahead.com/resources/how-to-create-custom-ec2-vpcs-in-aws-using-terraform/ */