output "vpcs_id" {
  value       = module.DevNetwork_vpc.vpcs_id
}

output "subnets_id" {
  value       = module.DevNetwork_vpc.subnets_id
}

output "tgws_id" {
  value       = module.DevNetwork_vpc.tgws_id
}

output "account_id" {
  value       = data.aws_caller_identity.current.account_id
}