provider "aws" {
  region = "ap-northeast-2" 
}

module "DevNetwork_vpc" {
  source = "/terraform/Mod/Ldz/Network/"
  vpcs = var.DevNetwork_vpc
  vpcs_cidr = var.DevNetworkVpc_cidr
  vpcs_names = var.DevNetworkVpc_name
  azs = var.Dev_az
  subnets = var.DevNetworkVpc_subnet
  subnets_cidr = var.DevNetworkVpcSubnet_cidr
  subnets_names = var.DevNetworkVpcSubnet_name
  tgws_name = var.tgws_name
  service_cidr = var.Dev_Service_cidr
  account_id = var.DevSvc_accountid
}

module "DevNetwork_ec2" {
  source = "/terraform/Mod/Ldz/Compute"
  Bastion_ami = var.Dev_Bastion_ami 
  Bastion_ec2_type = var.Dev_Bastion_ec2_type 
  Bastion_subnet_id = module.DevNetwork_vpc.subnets_id
  Bastion_port = var.Dev_Bastion_port
  Bastion_accpet_cidr = var.Dev_Bastion_accpet_cidr
  Bastion_ec2_name = var.Dev_Bastion_ec2_name
  Network_vpc_id = module.DevNetwork_vpc.vpcs_id 
}

data "aws_caller_identity" "current" {}
