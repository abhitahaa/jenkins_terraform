provider "aws" {
  region = "us-east-1"
}

variable "vpc_cidr_block" {}
#variable "subnet_cidr_block" {}
variable "env_prefix" {}
variable "my_ip" {}
#variable "instance_type" {}
#variable "public_key_location" {}
#variable "windows_key" {}


#VPC creation
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name : "${var.env_prefix}-testmainvpc"
  }
}