resource "aws_vpc" "vpcs" {
  count = length(var.vpcs)   
  cidr_block = var.vpcs_cidr[count.index]
  tags = {
    Name = var.vpcs_names[count.index]
  }
}

resource "aws_subnet" "subnets" {
  count = length(var.subnets)  
  vpc_id            = aws_vpc.vpcs[0].id
  cidr_block        = var.subnets_cidr[count.index]  
  availability_zone = var.azs[count.index % length(var.azs)] ## 서브넷 4개가 번갈아 생성되며, var.azs[ 0 ~ 1 % 2 ]의 나머지 값인 0,1이 반복되면서 해당 리스트 인덱싱 값의 가용영역 지정.  
  map_public_ip_on_launch = count.index < 2 ? true : false
  tags = {
    Name = var.subnets_names[count.index]  
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpcs[0].id
}

resource "aws_route_table" "Ext_route_table" {
  vpc_id = aws_vpc.vpcs[0].id

  tags = {
    Name = "Ext_route_table"
  }
}

resource "aws_route" "Ext_route" {
  route_table_id         = aws_route_table.Ext_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "Ext_table_assoc" {
  count = 2
  subnet_id      = aws_subnet.subnets[count.index].id
  route_table_id = aws_route_table.Ext_route_table.id
}

resource "aws_ec2_transit_gateway" "tgws" {
  count = 1
    auto_accept_shared_attachments = "enable"  
    default_route_table_association = "enable"
    default_route_table_propagation = "enable"
  tags = {
    Name = var.tgws_name
  }  
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_att" {
  count = 1
  subnet_ids         = [ 
    aws_subnet.subnets[2].id,
    aws_subnet.subnets[3].id
  ]

  tags = {
    Name = format("%s-%s", var.vpcs_names[0], var.tgws_name)
  }

  transit_gateway_id = aws_ec2_transit_gateway.tgws[0].id
  vpc_id             = aws_vpc.vpcs[0].id
}

resource "aws_ram_resource_share" "tgw_share" {
  name = "tgw_share"
  allow_external_principals = true

  tags = {
    Name = "tgw_share"
  }
}

resource "aws_ram_principal_association" "tgw_principal" {
  resource_share_arn = aws_ram_resource_share.tgw_share.arn
  principal          = var.account_id[0]  
}

resource "aws_ram_resource_association" "tgw_resource" {
  resource_share_arn = aws_ram_resource_share.tgw_share.arn
  resource_arn       = aws_ec2_transit_gateway.tgws[0].arn
}
