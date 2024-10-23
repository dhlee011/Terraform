PrdNetwork_vpc = [
    "PrdNetwork_Vpc"
]

PrdNetworkVpc_cidr = [
    "20.22.0.0/16"
]

PrdNetworkVpc_name =[
    "PrdNetwork_Vpc"
]

Prd_az = [
    "ap-northeast-2a",
    "ap-northeast-2c"
]

PrdNetworkVpc_subnet = [
    "EXT_subnet-a",
    "EXT_subnet-c",
    "TGW_subnet-a",
    "TGW_subnet-c"
]

PrdNetworkVpcSubnet_cidr = [
    "20.22.1.0/24",
    "20.22.2.0/24",
    "20.22.11.0/24",
    "20.22.12.0/24"
]

PrdNetworkVpcSubnet_name = [
    "EXT_subnet-a",
    "EXT_subnet-c",
    "TGW_subnet-a",
    "TGW_subnet-c"
]

Prd_Bastion_ami = ["ami-03439f5ccc1eeb443"]

Prd_Bastion_ec2_type = ["t2.micro"] 

Prd_Bastion_port = 22

Prd_Bastion_accpet_cidr = ["112.147.0.0/16", "118.235.0.0/16"]

Prd_Bastion_ec2_name = "Prd_Bastion"

tgws_name = "External"