resource "aws_instance" "nat_instance_pub1" {
  ami = "ami-0185fd13b4270de70"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.seoul_public_subnet1.id
  key_name = "${var.key_pair}"
  associate_public_ip_address = true
  source_dest_check = false

  tags = {
    Name = "nat_instance_pub1"
  }
}

resource "aws_security_group" "seoul_public_subnet1_sg" {
  name = "seoul-public-subnet1-sg"
  vpc_id = aws_vpc.seoul.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["10.1.3.0/24"]

  }
}


resource "aws_network_interface_sg_attachment" "seoul_nat_pub1_sg_attachment" {
  security_group_id    = aws_security_group.seoul_public_subnet1_sg.id
  network_interface_id = aws_instance.nat_instance_pub1.primary_network_interface_id

}




resource "aws_instance" "web_instance1" {
  ami = "ami-0e4a9ad2eb120e054"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.seoul_private_subnet1.id
  key_name = "${var.key_pair}"
  associate_public_ip_address = false
    user_data = file("web.sh")
  private_ip = "10.1.3.100"
  tags = {
    Name = "web1"
  }
}



resource "aws_security_group" "seoul_private_subnet1_sg" {
  name = "seoul-private-subnet1-sg"
  vpc_id = aws_vpc.seoul.id
}


resource "aws_security_group_rule" "seoul_private_subnet1_sg_rule" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.seoul_private_subnet1_sg.id

  source_security_group_id = aws_security_group.seoul_public_subnet1_sg.id
}


resource "aws_network_interface_sg_attachment" "seoul_private_subnet1_sg_attachment" {
  security_group_id    = aws_security_group.seoul_private_subnet1_sg.id
  network_interface_id = aws_instance.web_instance1.primary_network_interface_id

}


resource "aws_route_table" "seoul_private1_rt" {
  vpc_id = aws_vpc.seoul.id

  route {
    cidr_block = "0.0.0.0/0"
    instance_id = aws_instance.nat_instance_pub1.id
  }

  tags = {
    Name = "seoul-private1-rt"

  }
}

resource "aws_route_table_association" "route_table_association_seoul_private1_rt_attch" {
  subnet_id = aws_subnet.seoul_private_subnet1.id
  route_table_id = aws_route_table.seoul_private1_rt.id
}



resource "aws_instance" "nat_instance_pub2" {
  ami = "ami-0185fd13b4270de70"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.seoul_public_subnet2.id
  key_name = "${var.key_pair}"
  associate_public_ip_address = true
  source_dest_check = false

  tags = {
    Name = "nat-instance_pub2"
  }
}


resource "aws_security_group" "seoul_public_subnet2_sg" {
  name = "seoul-public-subnet2-sg"
  vpc_id = aws_vpc.seoul.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["10.1.3.0/24"]

  }
}


resource "aws_network_interface_sg_attachment" "seoul_nat_instance_pub2_sg_attachment" {
  security_group_id    = aws_security_group.seoul_public_subnet2_sg.id
  network_interface_id = aws_instance.nat_instance_pub2.primary_network_interface_id

}


resource "aws_instance" "web_instance2" {
  ami = "ami-0e4a9ad2eb120e054"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.seoul_private_subnet2.id
  key_name = "${var.key_pair}"
  associate_public_ip_address = false
    user_data = file("web.sh")
  private_ip = "10.1.4.100"
  tags = {
    Name = "web_instance2"
  }
}



resource "aws_security_group" "seoul_private_subnet2_sg" {
  name = "seoul-private-subnet2-sg"
  vpc_id = aws_vpc.seoul.id
}


resource "aws_security_group_rule" "seoul_private_subnet2_sg_rule" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.seoul_private_subnet2_sg.id

  source_security_group_id = aws_security_group.seoul_public_subnet2_sg.id
}


resource "aws_network_interface_sg_attachment" "seoul_private_subnet2_sg_attachment" {
  security_group_id    = aws_security_group.seoul_private_subnet2_sg.id
  network_interface_id = aws_instance.web_instance2.primary_network_interface_id

}



resource "aws_route_table" "seoul_private2_rt" {
  vpc_id = aws_vpc.seoul.id

  route {
    cidr_block = "0.0.0.0/0"
    instance_id = aws_instance.nat_instance_pub2.id
  }

  tags = {
    Name = "seoul-private2-rt"

  }
}

resource "aws_route_table_association" "route_table_association_seoul_private2_rt_attch" {
  subnet_id = aws_subnet.seoul_private_subnet2.id
  route_table_id = aws_route_table.seoul_private2_rt.id
}






resource "aws_instance" "dns_instance1" {
  ami = "ami-0e4a9ad2eb120e054"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.seoul_idc_subnet1.id
  key_name = "${var.key_pair}"
  associate_public_ip_address = false
    user_data = file("web.sh")
  private_ip = "10.2.1.200"
  tags = {
    Name = "dns_instance1"
  }
}

resource "aws_security_group" "seoul_idc_subnet1_sg_dns" {
  name = "seoul-idc-subnet1-sg"
  vpc_id = aws_vpc.seoul_idc.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 53
    to_port = 53
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }


}


resource "aws_network_interface_sg_attachment" "seoul_idc_subnet1_sg_attachment" {
  security_group_id    = aws_security_group.seoul_idc_subnet1_sg_dns.id
  network_interface_id = aws_instance.dns_instance1.primary_network_interface_id

}



resource "aws_instance" "db_instance1" {
  ami = "ami-0e4a9ad2eb120e054"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.seoul_idc_subnet1.id
  key_name = "${var.key_pair}"
  associate_public_ip_address = false
    user_data = file("web.sh")
  private_ip = "10.2.1.100"
  tags = {
    Name = "db_instance1"
  }
}

resource "aws_security_group" "seoul_idc_subnet1_sg_db" {
  name = "seoul-idc-subnet1-sg-db"
  vpc_id = aws_vpc.seoul_idc.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 53
    to_port = 53
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

}


resource "aws_network_interface_sg_attachment" "seoul_idc_subnet1_sg_attachment2" {
  security_group_id    = aws_security_group.seoul_idc_subnet1_sg_db.id
  network_interface_id = aws_instance.db_instance1.primary_network_interface_id

}


resource "aws_instance" "seoul_idc_cgw" {
  ami = "ami-0bd7691bf6470fe9c"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.seoul_idc_subnet1.id
  key_name = "${var.key_pair}"
  user_data = file("./cgw.sh")
  associate_public_ip_address = true
  source_dest_check = false
  private_ip = "10.2.1.150"
  tags = {
    Name = "seoul_idc_cgw"
  }
}


resource "aws_security_group" "seoul_idc_subnet1_sg_cgw" {
  name = "seoul-idc-subnet1-sg-cgw"
  vpc_id = aws_vpc.seoul_idc.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 53
    to_port = 53
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }


}


resource "aws_network_interface_sg_attachment" "seoul_idc_subnet1_sg_attachment3" {
  security_group_id    = aws_security_group.seoul_idc_subnet1_sg_cgw.id
  network_interface_id = aws_instance.seoul_idc_cgw.primary_network_interface_id

}


=============================================================================================================================================================================
  

#싱가포르

resource "aws_instance" "nat_instance_pub1" {
  ami = "ami-0096082b44d750d5d"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.singapore_public_subnet1.id
  key_name = "${var.key_pair}"
  associate_public_ip_address = true
  source_dest_check = false

  tags = {
    Name = "nat-instance-pub1"
  }
}


resource "aws_security_group" "singapore_public_subnet1_sg" {
  name = "singapore-public-subnet1-sg"
  vpc_id = aws_vpc.singapore.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["10.1.3.0/24"]

  }
}


resource "aws_network_interface_sg_attachment" "singapore_nat_pub1_sg_attachment" {
  security_group_id    = aws_security_group.singapore_public_subnet1_sg.id
  network_interface_id = aws_instance.nat_instance_pub1.primary_network_interface_id

}


resource "aws_instance" "web_instance1" {
  ami = "ami-073998ba87e205747"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.singapore_private_subnet1.id
  key_name = "${var.key_pair}"
  associate_public_ip_address = false
    user_data = file("web.sh")
  private_ip = "10.3.3.100"
  tags = {
    Name = "web1-instance1"
  }
}



resource "aws_security_group" "singapore_private_subnet1_sg" {
  name = "singapore-private-subnet1-sg"
  vpc_id = aws_vpc.singapore.id
}


resource "aws_security_group_rule" "singapore_private_subnet1_sg_rule" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.singapore_private_subnet1_sg.id

  source_security_group_id = aws_security_group.singapore_public_subnet1_sg.id
}


resource "aws_network_interface_sg_attachment" "singapore_private_subnet1_sg_attachment" {
  security_group_id    = aws_security_group.singapore_private_subnet1_sg.id
  network_interface_id = aws_instance.web_instance1.primary_network_interface_id

}



resource "aws_route_table" "singapore_private1_rt" {
  vpc_id = aws_vpc.singapore.id

  route {
    cidr_block = "0.0.0.0/0"
    instance_id = aws_instance.nat_instance_pub1.id
  }

  tags = {
    Name = "singapore-private1-rt"

  }
}

resource "aws_route_table_association" "route_table_association_singapore_private1_rt_attch" {
  subnet_id = aws_subnet.singapore_private_subnet1.id
  route_table_id = aws_route_table.singapore_private1_rt.id
}






resource "aws_instance" "dns_instance1" {
  ami = "ami-073998ba87e205747"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.singapore_idc_subnet1.id
  key_name = "${var.key_pair}"
  associate_public_ip_address = false
    user_data = file("web.sh")
  private_ip = "10.4.1.200"
  tags = {
    Name = "dns_instance1"
  }
}

resource "aws_security_group" "singapore_idc_subnet1_sg_dns" {
  name = "singapore-idc-subnet1-sg"
  vpc_id = aws_vpc.singapore_idc.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 53
    to_port = 53
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }


}


resource "aws_network_interface_sg_attachment" "singapore_idc_subnet1_sg_attachment" {
  security_group_id    = aws_security_group.singapore_idc_subnet1_sg_dns.id
  network_interface_id = aws_instance.dns_instance1.primary_network_interface_id

}



resource "aws_instance" "db_instance1" {
  ami = "ami-073998ba87e205747"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.singapore_idc_subnet1.id
  key_name = "${var.key_pair}"
  associate_public_ip_address = false
    user_data = file("web.sh")
  private_ip = "10.4.1.100"
  tags = {
    Name = "db_instance1"
  }
}

resource "aws_security_group" "singapore_idc_subnet1_sg_db" {
  name = "singapore-idc-subnet1-sg-db"
  vpc_id = aws_vpc.singapore_idc.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 53
    to_port = 53
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

}


resource "aws_network_interface_sg_attachment" "singapore_idc_subnet1_sg_attachment2" {
  security_group_id    = aws_security_group.singapore_idc_subnet1_sg_db.id
  network_interface_id = aws_instance.db_instance1.primary_network_interface_id

}


resource "aws_instance" "singapore_idc_cgw" {
  ami = "ami-0cd31be676780afa7"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.singapore_idc_subnet1.id
  key_name = "${var.key_pair}"
  user_data = file("./cgw.sh")
  associate_public_ip_address = true
  private_ip = "10.4.1.150"
  tags = {
    Name = "singapore_idc_cgw"
  }
}


resource "aws_security_group" "singapore_idc_subnet1_sg_cgw" {
  name = "singapore-idc-subnet1-sg-cgw"
  vpc_id = aws_vpc.singapore_idc.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 53
    to_port = 53
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }


}


resource "aws_network_interface_sg_attachment" "singapore_idc_subnet1_sg_attachment3" {
  security_group_id    = aws_security_group.singapore_idc_subnet1_sg_cgw.id
  network_interface_id = aws_instance.singapore_idc_cgw.primary_network_interface_id

}
