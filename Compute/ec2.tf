resource "aws_instance" "Bastion_ec2" {
  ami                    = var.Bastion_ami[0]
  instance_type          = var.Bastion_ec2_type[0]
  subnet_id              = var.Bastion_subnet_id[0]

  tags = {
    Name = "Test_EC2"
  }
}





