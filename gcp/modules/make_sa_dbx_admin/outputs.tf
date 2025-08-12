
output "granted_admin_account" {
  value       = databricks_user_role.my_user_account_admin.id
  description = "This email was added to the Databricks account as an admin user."
  
}

output "original_admin_account" {
  value       = var.dbx_existing_admin_account
  description = "This is the original admin account that was used to create the Databricks provider."
}