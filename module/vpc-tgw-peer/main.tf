
provider "aws" {

  region = var.region
}


resource "aws_vpc" "default" {
  cidr_block           = "${var.region_numeral}.${var.cidr_numeral}.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "${var.region_name}-${var.vpc_name}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "igw-${var.vpc_name}"
  }
}


resource "aws_nat_gateway" "nat" {
  count = length(var.availability_zones_without_b)
  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id = element(aws_subnet.public.*.id, count.index)
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_internet_gateway.default]

  tags = {
    Name = "NAT-GW${count.index}-${var.vpc_name}"
  }

}

resource "aws_eip" "nat" {
  # Count value should be same with that of aws_nat_gateway because all nat will get elastic ip
  count = length(var.availability_zones_without_b)
  vpc   = true

  lifecycle {
    create_before_destroy = true
  }
}



resource "aws_subnet" "public" {
  count  = length(var.availability_zones_without_b)
  vpc_id = aws_vpc.default.id

  cidr_block        = "${var.region_numeral}.${var.cidr_numeral}.${var.cidr_numeral_public[count.index]}.0/24"
  availability_zone = element(var.availability_zones_without_b, count.index)


  map_public_ip_on_launch = true

  tags = {
    Name = "public${count.index}-${var.vpc_name}"


  }
}

# Route Table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }

  tags = {
    Name = "publicrt-${var.vpc_name}"
  }
}


# Route Table Association for public subnets
resource "aws_route_table_association" "public" {
  count          = length(var.availability_zones_without_b)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}



#### PRIVATE SUBNETS
# Subnet will use cidr with /20 -> The number of available IP is 4,096  (Including reserved ip from AWS)
resource "aws_subnet" "private" {
  count  = var.private_subnet # ???????????? ??? ?????? ??????
  vpc_id = aws_vpc.default.id

  cidr_block        = "${var.region_numeral}.${var.cidr_numeral}.${var.cidr_numeral_private[count.index]}.0/24" #?????? ??????.
  availability_zone = element(var.availability_zones_without_b, count.index) # ????????? ?????? ???????????? ???????????? ???????????? ??????.

  tags = { #????????? ??? ???????????? ????????????.
    Name               = "private${count.index}-${var.vpc_name}"
    Network            = "Private"
  }
}

# Route Table for private subnets
resource "aws_route_table" "private" {
  count  = length(var.availability_zones_without_b)
  vpc_id = aws_vpc.default.id

  route {
  cidr_block = "0.0.0.0/0"
  nat_gateway_id = element(aws_nat_gateway.nat.*.id, count.index)
  }

  tags = {
    Name    = "private${count.index}rt-${var.vpc_name}"
    Network = "Private"

  }
}


# Route Table Association for private subnets
resource "aws_route_table_association" "private" {
  count          = length(var.availability_zones_without_b)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

#sg

resource "aws_security_group" "manage-ec2-sg" {
  name = "manage-ec2-sg"
  vpc_id = aws_vpc.default.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

   }

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks      = ["0.0.0.0/0"]

  }
}





# tgw ????????? EC2
resource "aws_instance" "Bastion Host" {
  ami = "ami-0dc5785603ad4ff54" 
  instance_type = "t2.micro"
  key_name = var.key_pair
  vpc_security_group_ids = [aws_security_group.manage-ec2-sg.id]

  user_data       = data.template_file.user_data.rendered
  subnet_id              = aws_subnet.public[0].id
  tags = {
    Name = "Bastion Host"
  }

}

data "template_file" "user_data" {
  template = file("${path.module}/user-data.sh")
  vars = {
    region_name = var.region_name
    vpc_name = var.vpc_name
  }
}


#### tgw ????????? PRIVATE SUBNETS ??????
resource "aws_subnet" "private-tgw" {
  count  = var.private_subnet_tgw
  vpc_id = aws_vpc.default.id

  cidr_block        = "${var.region_numeral}.${var.cidr_numeral}.${var.cidr_numeral_private_tgw[count.index]}.0/24" #?????? ??????.
  availability_zone = element(var.availability_zones_without_b, count.index) # ????????? ?????? ???????????? ???????????? ???????????? ??????.

  tags = {
    Name               = "private-tgw${count.index}-${var.vpc_name}"
    Network            = "Private"
  }
}

# tgw ????????? Route Table for private subnets
resource "aws_route_table" "private-tgw" {
  count  = length(var.availability_zones_without_b)
  vpc_id = aws_vpc.default.id

  route {
  cidr_block = "0.0.0.0/0"
  nat_gateway_id = element(aws_nat_gateway.nat.*.id, count.index)
  }

  tags = {
    Name    = "private-tgw"
    Network = "Private"

  }
}


# tgw ????????? Route Table Association for private subnets
resource "aws_route_table_association" "private-tgw" {
  count          = length(var.availability_zones_without_b)
  subnet_id      = element(aws_subnet.private-tgw.*.id, count.index)
  route_table_id = element(aws_route_table.private-tgw.*.id, count.index)
}





# TGW ??????
resource "aws_ec2_transit_gateway" "test-tgw" {


  description                     = "test-transit-gateway"
  auto_accept_shared_attachments  = "disable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  tags = {
    Name = "test-transit-gateway"
  }
}




# tgw vpc ??????
resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_attachment" {
  subnet_ids                                      = flatten([aws_subnet.private-tgw.*.id])
  transit_gateway_id                              = aws_ec2_transit_gateway.test-tgw.id
  vpc_id                                          = aws_vpc.default.id

  depends_on = [
    "aws_ec2_transit_gateway.test-tgw",
    "aws_subnet.private-tgw"
  ]
}


# peering
data "aws_caller_identity" "singapore" {
}

data "aws_region" "singapore" {
}

# Create the Peering attachment in the seoul account...
resource "aws_ec2_transit_gateway_peering_attachment" "peer_att" {


  peer_account_id         = var.seoul_account_id
  peer_region             = var.seoul_region
  peer_transit_gateway_id = var.tgw
  transit_gateway_id      = aws_ec2_transit_gateway.test-tgw.id
  tags = {
    Name = "tgw-att"
    Side = "Creator"
  }
  depends_on = [
    "var.tgw"
  ]  
}

# ?????? vpc ????????? ??????
data "aws_ec2_transit_gateway_route_table" "peer_rt" {
  filter {
    name   = "default-association-route-table"
    values = ["true"]
  }
  depends_on = [
    "aws_ec2_transit_gateway.test-tgw"
  ]

}

# tgw ?????? ??????
resource "aws_ec2_transit_gateway_route" "example" {
  destination_cidr_block         = "10.0.0.0/8"
  transit_gateway_attachment_id  = var.peer_att.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.peer_rt.id
  depends_on = [
    "var.tgw"
  ]
}

resource "aws_route" "to-trgw-peer" {

  route_table_id         = aws_route_table.public.id
  transit_gateway_id     = aws_ec2_transit_gateway.test-tgw.id
  destination_cidr_block = "10.0.0.0/8"

}