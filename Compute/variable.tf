variable "Bastion_ami" {  ## 단일 문자열 필요해서 ec2.tf에서 인덱싱
  type = list(string)  
}

variable "Bastion_ec2_type" {
  type = list(string)
}

#variable "Dev_vpc_id" {
#  type = list(string)
#}

variable "Bastion_subnet_id" {
  type = list(string) 
}
