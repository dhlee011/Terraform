output "vpcs_id" {
  value = aws_vpc.vpcs[*].id
}

output "subnets_id" {
  value = aws_subnet.subnets[*].id  # 모든 서브넷의 ID를 리스트로 반환
}
