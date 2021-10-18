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
