module "service_account" {
  source                      = "../../modules/service_account/"
  project       = var.project
  prefix = var.prefix
  delegate_from = var.delegate_from
}

output "custom_role_url" {
  value = "https://console.cloud.google.com/iam-admin/roles/details/projects%3C${module.service_account.current_project}%3Croles%3C${module.service_account.role_id}"
}

output "service_account" {
  value       = module.service_account.service_account
  description = "Add this email as a user in the Databricks account console"
}
