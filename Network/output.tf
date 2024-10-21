output "vpcs_id" {
  value = aws_vpc.vpcs[*].id
}

output "subnets_id" {
  value = aws_subnet.subnets[*].id  
}

output "tgws_id" {
  value = aws_ec2_transit_gateway.tgws[*].id  
}

