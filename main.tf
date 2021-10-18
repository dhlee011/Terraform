resource "aws_vpc" "seoul" {
  cidr_block = "10.1.0.0/16"

  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "seoul_vpc"
  }
}


resource "aws_subnet" "seoul_public_subnet1" {
  vpc_id = aws_vpc.seoul.id
  cidr_block = "10.1.1.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "seoul-public-subnet1"
  }
}

resource "aws_subnet" "seoul_public_subnet2" {
  vpc_id = aws_vpc.seoul.id
  cidr_block = "10.1.2.0/24"

  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "seoul-public-subnet2"
  }
}

resource "aws_subnet" "seoul_private_subnet1" {
  vpc_id = aws_vpc.seoul.id
  cidr_block = "10.1.3.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "seoul-private-subnet1"
  }
}

resource "aws_subnet" "seoul_private_subnet2" {
  vpc_id = aws_vpc.seoul.id
  cidr_block = "10.1.4.0/24"

  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "seoul-private-subnet2"
  }
}


resource "aws_subnet" "seoul_TGW_subnet1" {
  vpc_id = aws_vpc.seoul.id

  availability_zone = "ap-northeast-2a"

  cidr_block = "10.1.5.0/24"
  tags = {
    Name = "seoul_TGW_subnet1"
  }
}


resource "aws_subnet" "seoul_TGW_subnet2" {
  vpc_id = aws_vpc.seoul.id

  availability_zone = "ap-northeast-2c"

  cidr_block = "10.1.6.0/24"
  tags = {
    Name = "seoul_TGW_subnet2"
  }
}




resource "aws_internet_gateway" "seoul_igw" {
  vpc_id = aws_vpc.seoul.id

  tags = {
    Name = "seoul-igw"
  }
}



resource "aws_route_table" "seoul_public" {
  vpc_id = aws_vpc.seoul.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.seoul_igw.id
  }

  tags = {
    Name = "seoul-rt-public"

  }
}




resource "aws_route_table_association" "route_table_association_public1" {
  subnet_id = aws_subnet.seoul_public_subnet1.id
  route_table_id = aws_route_table.seoul_public.id
}

resource "aws_route_table_association" "route_table_association_public2" {
  subnet_id = aws_subnet.seoul_public_subnet2.id
  route_table_id = aws_route_table.seoul_public.id
}

resource "aws_vpc" "seoul_idc" {
  cidr_block = "10.2.0.0/16"

  enable_dns_support = true
  enable_dns_hostnames = true


  tags = {
    Name = "seoul-idc"
  }
}


resource "aws_subnet" "seoul_idc_subnet1" {
  vpc_id = aws_vpc.seoul_idc.id
  cidr_block = "10.2.1.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "seoul-idc-subnet1"
  }
}


resource "aws_internet_gateway" "seoul_idc_igw" {
  vpc_id = aws_vpc.seoul_idc.id

  tags = {
    Name = "seoul_idc-igw"
  }
}



resource "aws_route_table" "seoul_idc_rt" {
  vpc_id = aws_vpc.seoul_idc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.seoul_idc_igw.id
  }

  tags = {
    Name = "seoul_idc-rt-public"

  }
}


resource "aws_route_table_association" "route_table_association_seoul_idc" {
  subnet_id = aws_subnet.seoul_idc_subnet1.id
  route_table_id = aws_route_table.seoul_idc_rt.id

  
  resource "aws_customer_gateway" "cgw" {
  bgp_asn    = 65000
  ip_address = "52.79.153.38"
  type       = "ipsec.1"

  tags = {
    Name = "seoul-idc-cgw"
  }
}

resource "aws_ec2_transit_gateway" "seoul_tgw" {
  description = "seoul_tgw"
}

resource "aws_ec2_transit_gateway_vpc_attachment" "seoul_tgw_vpc" {
  subnet_ids         = [aws_subnet.seoul_TGW_subnet1.id, aws_subnet.seoul_TGW_subnet1.id]
  transit_gateway_id = aws_ec2_transit_gateway.seoul_tgw.id
  vpc_id             = aws_vpc.seoul.id

  tags = {
    name = "seoul-tgw-vpc"

  }
}


resource "aws_vpn_connection" "seoul_tgw_vpn" {
  customer_gateway_id = aws_customer_gateway.cgw.id
  transit_gateway_id  = aws_ec2_transit_gateway.seoul_tgw.id
  type                = aws_customer_gateway.cgw.type

  static_routes_only = true

  tunnel1_preshared_key = "cloudneta"

  tunnel2_preshared_key = "cloudneta"


}

data "aws_ec2_transit_gateway_vpn_attachment" "seoul-cgw-tgw" {
  transit_gateway_id = aws_ec2_transit_gateway.seoul_tgw.id
  vpn_connection_id  = aws_vpn_connection.seoul_tgw_vpn.id
}


resource "aws_ec2_transit_gateway_route" "seoul_tgw_route" {
  destination_cidr_block         = "10.0.0.0/8"
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpn_attachment.seoul-cgw-tgw.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.seoul_tgw.association_default_route_table_id
}



resource "aws_ec2_transit_gateway_peering_attachment" "seoul-peering-singapore" {
  peer_region             = "ap-southeast-1"
  peer_transit_gateway_id = "tgw-0ebd2201f0841cd50"
  transit_gateway_id      = "tgw-09f51ee7218ad7241"

  tags = {
    Name = "seoul-peering-singapore"
  }
}
