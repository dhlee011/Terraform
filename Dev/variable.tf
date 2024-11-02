variable "DevSvc_vpc" {
  type = list(string)
}

variable "DevSvcVpc_cidr" {
  type = list(string)
}

variable "DevSvcVpc_name" {
  type = list(string)
}

variable "Dev_az" {
  type = list(string)
}

variable "DevSvcVpc_subnet" {
  type = list(string)
}

variable "DevSvcVpcSubnet_cidr" {
  type = list(string)
}

variable "DevSvcVpcSubnet_name" {
  type = list(string)
}

variable "tgw_name" {
  type = string
}

variable "bucket" {
  type = string
}

variable "LdzBucket_key" {
  type = string
}

variable "region" {
  type = string
}