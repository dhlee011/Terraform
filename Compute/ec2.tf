resource "aws_instance" "Bastion_ec2" {
  ami                    = var.Bastion_ami[0]
  instance_type          = var.Bastion_ec2_type[0]
  subnet_id              = var.Bastion_subnet_id[0]

  tags = {
    Name = "var.Bastion_ec2_name"
  }
}

resource "aws_security_group" "Bastion_sg" {
  name        = "Bastion_sg"
  vpc_id      = var.Dev_vpc_id[0]
  ingress {
    from_port   = var.Bastion_port
    to_port     = var.Bastion_port
    protocol    = "tcp"
    cidr_blocks = var.Bastion_accpet_cidr
  }
}


