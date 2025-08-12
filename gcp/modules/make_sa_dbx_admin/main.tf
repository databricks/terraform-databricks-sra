resource "databricks_user" "sa" {
  provider = databricks
  display_name         = "SA for Account Provisionning"
  user_name = var.new_admin_account
}
resource "databricks_user_role" "my_user_account_admin" {
  provider = databricks
  user_id = databricks_user.sa.id
  role    = "account_admin"
}