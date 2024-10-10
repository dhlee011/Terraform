provider "aws" {
  region = "ap-northeast-2" 
}

module "Dev_vpc" {
  source = "/terraform/Mod/Network"
  vpcs = var.Dev_vpc
  vpcs_cidr = var.Dev_vpc_cidr
  vpcs_names = var.Dev_vpc_name
  azs = var.Dev_az
  subnets = var.Dev_subnet
  subnets_cidr = var.Dev_subnet_cidr
  subnets_names = var.Dev_subnet_name
}




