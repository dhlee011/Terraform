
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
  availability_zone = var.azs[count.index % length(var.azs)]   
  map_public_ip_on_launch = false
  tags = {
    Name = var.subnets_names[count.index]  
  }
}

resource "aws_ram_resource_share_accepter" "tgw_share_accepter" {
  share_arn = var.tgw_share_arn
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_att" {
  count = 1
  subnet_ids         = [ 
    aws_subnet.subnets[2].id,
    aws_subnet.subnets[3].id
  ]

  tags = {
    Name = format("%s-%s", var.vpcs_names[0], var.tgw_name)
  }

  transit_gateway_id = var.tgw_id[0]
  vpc_id             = aws_vpc.vpcs[0].id
}
