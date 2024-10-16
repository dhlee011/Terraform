
variable "Dev_vpc" {
  type = list(string)
}

variable "Dev_vpc_cidr" {
  type = list(string)
}

variable "Dev_vpc_name" {
  type = list(string)
}

variable "Dev_az" {
  type = list(string)
}

variable "Dev_subnet" {
  type = list(string)
}

variable "Dev_subnet_cidr" {
  type = list(string)
}

variable "Dev_subnet_name" {
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