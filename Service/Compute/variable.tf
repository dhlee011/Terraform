variable "ekscluster_name" {
  type = string
}

variable "eksnodegroup_name" {
  type = string
}

variable "eks_vpc" {
  type = list(string)
}

variable "eks_subnet" {
  type = list(string)
}

variable "launch_template" {
  type = string
}

variable "eksNode_ami" {
  type = string
}

variable "Bastion_ami" {
  type = string
}

variable "Bastion_ec2_name" {
  type = string
}

