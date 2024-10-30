
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

