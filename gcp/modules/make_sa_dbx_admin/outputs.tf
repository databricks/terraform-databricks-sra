
output "granted_admin_account" {
  value       = databricks_user_role.my_user_account_admin.id
  description = "This email was added to the Databricks account as an admin user."

}

output "original_admin_account" {
  value       = var.dbx_existing_admin_account
  description = "This is the original admin account that was used to create the Databricks provider."
}

# Emits the newly-admined SA email, but only after the account_admin role has
# actually been granted. Consumers (e.g. the workspace_deployment module, which
# cannot take depends_on because it declares its own providers) should wire their
# databricks_google_service_account to THIS output so the workspace is not
# created until the SA is a Databricks account admin.
output "admin_service_account" {
  value       = var.new_admin_account
  depends_on  = [databricks_user_role.my_user_account_admin]
  description = "The provisioning SA email, emitted only after it is granted account_admin."
}