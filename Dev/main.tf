provider "aws" {
  region = "ap-northeast-2" 
}

data "terraform_remote_state" "tgw_share_arn" {
  backend = "s3"
  config = {
    bucket = var.bucket
    key    = var.LdzBucket_key  
    region = var.region
  }
}

data "terraform_remote_state" "tgw_id" {
  backend = "s3"
  config = {
    bucket = var.bucket
    key    = var.LdzBucket_key  
    region = var.region
  }
}

data "aws_caller_identity" "current" {}

module "DevSvc_vpc" {
  source = "/terraform/Mod/Svc/Network/"
  vpcs = var.DevSvc_vpc
  vpcs_cidr = var.DevSvcVpc_cidr
  vpcs_names = var.DevSvcVpc_name
  azs = var.Dev_az
  subnets = var.DevSvcVpc_subnet
  subnets_cidr = var.DevSvcVpcSubnet_cidr
  subnets_names = var.DevSvcVpcSubnet_name
  tgw_share_arn = data.terraform_remote_state.tgw_share_arn.outputs.tgwshare_id
  tgw_id = data.terraform_remote_state.tgw_id.outputs.tgws_id
  tgw_name = var.tgw_name
}

module "DevSvc_compute" {
  source = "/terraform/Mod/Svc/Compute/"
  eks_vpc = module.DevSvc_vpc.vpcs_id
  eks_subnet = module.DevSvc_vpc.subnets_id
  ekscluster_name = var.DevSvcEksClster_name
  eksnodegroup_name = var.DevSvcEksNodeGroup_name
  launch_template = var.DevSvcLaunch_template
  eksNode_ami = var.DevSvcEksNode_ami
  Bastion_ami = var.Dev_Bastion_ami
  Bastion_ec2_name = var.Dev_Bastion_ec2_name
}
