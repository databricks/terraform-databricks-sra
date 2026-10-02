module "service_account" {
  source        = "../../modules/service_account/"
  project       = var.project
  sa_name       = var.sa_name
  delegate_from = var.delegate_from
}

output "custom_role_url" {
  value = module.service_account.custom_role_url
}

output "service_account_email" {
  value       = module.service_account.workspace_creator_email
  description = "Add this email as a user in the Databricks account console"
}
