
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
  tags = {
    Name = var.subnets_names[count.index]  
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpcs[0].id
}

