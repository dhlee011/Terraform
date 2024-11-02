output "vpcs_id" {
  value       = module.DevSvc_vpc.vpcs_id
}

output "subnets_id" {
  value       = module.DevSvc_vpc.subnets_id
}

output "account_id" {
  value       = data.aws_caller_identity.current.account_id
}