locals {
  region = "ap-northeast-2"
}

resource "aws_vpc" "vpcs" {
  count = length(var.vpcs)   
  cidr_block = var.vpcs_cidr[count.index]
  tags = {
    Name = var.vpcs_names[count.index]
  }
  enable_dns_hostnames = true
  enable_dns_support   = true
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

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpcs[0].id

  tags = {
    Name = "TgwRoute_table"
  }
}

resource "aws_route" "ext_route" {
  route_table_id         = aws_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = var.tgw_id[0]
}

resource "aws_route_table_association" "tgw_table_assoc" {
  count = 2
  subnet_id      = aws_subnet.subnets[count.index].id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_security_group" "eks_nodegroup_sg" {
  vpc_id = aws_vpc.vpcs[0].id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["30.33.0.0/16"]
  }

  tags = {
    Name = "eks_node_group_sg"
  }
}

resource "aws_vpc_endpoint" "ec2_endpoint" {
  vpc_id            = aws_vpc.vpcs[0].id
  service_name      = "com.amazonaws.${local.region}.ec2"
  vpc_endpoint_type = "Interface"
  subnet_ids         = [ 
    aws_subnet.subnets[0].id,
    aws_subnet.subnets[1].id
  ]
  security_group_ids = [aws_security_group.eks_nodegroup_sg.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecr_api_endpoint" {
  vpc_id            = aws_vpc.vpcs[0].id
  service_name      = "com.amazonaws.${local.region}.ecr.api"
  vpc_endpoint_type = "Interface"
  subnet_ids         = [ 
    aws_subnet.subnets[0].id,
    aws_subnet.subnets[1].id
  ]
  security_group_ids = [aws_security_group.eks_nodegroup_sg.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecr_dkr_endpoint" {
  vpc_id            = aws_vpc.vpcs[0].id
  service_name      = "com.amazonaws.${local.region}.ecr.dkr"
  vpc_endpoint_type = "Interface"
  subnet_ids         = [ 
    aws_subnet.subnets[0].id,
    aws_subnet.subnets[1].id
  ]
  security_group_ids = [aws_security_group.eks_nodegroup_sg.id]
  private_dns_enabled = true           ################ 하려면 VPC DNS 옵션 2개 활성화 필요.
}

resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id             = aws_vpc.vpcs[0].id
  service_name       = "com.amazonaws.${local.region}.s3"
  vpc_endpoint_type  = "Gateway"
  route_table_ids    = [aws_route_table.route_table.id]
}
