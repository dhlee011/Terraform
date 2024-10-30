
variable "PrdNetwork_vpc" {
  type = list(string)
}

variable "PrdNetworkVpc_cidr" {
  type = list(string)
}

variable "PrdNetworkVpc_name" {
  type = list(string)
}

variable "Prd_az" {
  type = list(string)
}

variable "PrdNetworkVpc_subnet" {
  type = list(string)
}

variable "PrdNetworkVpcSubnet_cidr" {
  type = list(string)
}

variable "PrdNetworkVpcSubnet_name" {
  type = list(string)
}

variable "Prd_Bastion_ami" {
  type = list(string)
}

variable "Prd_Bastion_ec2_type" {
  type = list(string)
}

variable "Prd_Bastion_ec2_name" {
  type = string
}

variable "Prd_Bastion_accpet_cidr" {
  type = list(string)
}

variable "Prd_Bastion_port" {
  type = number
}

variable "tgws_name" {
  type = string
}