DevNetwork_vpc = [
    "DevNetwork_Vpc"
]

DevNetworkVpc_cidr = [
    "10.11.0.0/16"
]

DevNetworkVpc_name =[
    "DevNetwork_Vpc"
]

Dev_az = [
    "ap-northeast-2a",
    "ap-northeast-2c"
]

DevNetworkVpc_subnet = [
    "EXT_subnet-a",
    "EXT_subnet-c",
    "TGW_subnet-a",
    "TGW_subnet-c"
]

DevNetworkVpcSubnet_cidr = [
    "10.11.1.0/24",
    "10.11.2.0/24",
    "10.11.11.0/24",
    "10.11.12.0/24"
]

DevNetworkVpcSubnet_name = [
    "EXT_subnet-a",
    "EXT_subnet-c",
    "TGW_subnet-a",
    "TGW_subnet-c"
]

Dev_Bastion_ami = ["ami-03439f5ccc1eeb443"]

Dev_Bastion_ec2_type = ["t2.micro"] 

Dev_Bastion_port = 22

Dev_Bastion_accpet_cidr = ["112.147.0.0/16", "118.235.0.0/16"]

Dev_Bastion_ec2_name = "Dev_Bastion"

tgws_name = "Internal"