output "service_account_email" {
  value = module.service_account.workspace_creator_email
}

output "databricks_host" {
  value = module.customer_managed_vpc.databricks_host
}