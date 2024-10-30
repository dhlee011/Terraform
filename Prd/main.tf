provider "aws" {
  region = "ap-northeast-2" 
}

module "PrdNetwork_vpc" {
  source = "/terraform/Mod/Ldz/Network/"
  vpcs = var.PrdNetwork_vpc
  vpcs_cidr = var.PrdNetworkVpc_cidr
  vpcs_names = var.PrdNetworkVpc_name
  azs = var.Prd_az
  subnets = var.PrdNetworkVpc_subnet
  subnets_cidr = var.PrdNetworkVpcSubnet_cidr
  subnets_names = var.PrdNetworkVpcSubnet_name
#  tgws_name = var.tgws_name
}

module "PrdNetwork_ec2" {
  source = "/terraform/Mod/Ldz/Compute"
  Bastion_ami = var.Prd_Bastion_ami 
  Bastion_ec2_type = var.Prd_Bastion_ec2_type 
  Bastion_subnet_id = module.PrdNetwork_vpc.subnets_id
  Bastion_port = var.Prd_Bastion_port
  Bastion_accpet_cidr = var.Prd_Bastion_accpet_cidr
  Bastion_ec2_name = var.Prd_Bastion_ec2_name
  Network_vpc_id = module.PrdNetwork_vpc.vpcs_id 
}


