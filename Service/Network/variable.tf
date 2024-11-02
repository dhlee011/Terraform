
variable "vpcs" {
  type = list(string)
}

variable "vpcs_cidr" {
  type = list(string)
}

variable "vpcs_names" {
  type = list(string)
}

variable "azs" {
  type = list(string)
}

variable "subnets" {
  type = list(string)
}

variable "subnets_cidr" {
  type = list(string)
}

variable "subnets_names" {
  type = list(string)
}

variable "tgw_name" {
  type = string
}

variable "tgw_share_arn" {
  type = string
}

variable "tgw_id" {
  type = list(string)
}

