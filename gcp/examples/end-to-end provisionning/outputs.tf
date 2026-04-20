output "service_account_email" {
  value = module.service_account.workspace_creator_email
}

output "workspace_url" {
  value = module.customer_managed_vpc.workspace_url
}

output "workspace_id" {
  value = module.customer_managed_vpc.workspace_id
}
