
variable "DevNetwork_vpc" {
  type = list(string)
}

variable "DevNetworkVpc_cidr" {
  type = list(string)
}

variable "DevNetworkVpc_name" {
  type = list(string)
}

variable "Dev_az" {
  type = list(string)
}

variable "DevNetworkVpc_subnet" {
  type = list(string)
}

variable "DevNetworkVpcSubnet_cidr" {
  type = list(string)
}

variable "DevNetworkVpcSubnet_name" {
  type = list(string)
}

variable "Dev_Bastion_ami" {
  type = list(string)
}

variable "Dev_Bastion_ec2_type" {
  type = list(string)
}

variable "Dev_Bastion_ec2_name" {
  type = string
}

variable "Dev_Bastion_accpet_cidr" {
  type = list(string)
}

variable "Dev_Bastion_port" {
  type = number
}

variable "tgws_name" {
  type = string
}