provider "aws" {
  region = "ap-northeast-2" 
}

module "DevSvc_vpc" {
  source = "/terraform/Mod/Svc/Network/"
  vpcs = var.DevSvc_vpc
  vpcs_cidr = var.DevSvcVpc_cidr
  vpcs_names = var.DevSvcVpc_name
  azs = var.Dev_az
  subnets = var.DevSvcVpc_subnet
  subnets_cidr = var.DevSvcVpcSubnet_cidr
  subnets_names = var.DevSvcVpcSubnet_name
}


data "aws_caller_identity" "current" {}
