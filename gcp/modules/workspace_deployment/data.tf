
data "google_client_openid_userinfo" "me" {
    
}


# data "databricks_group" "admins" {
#  count = var.admin_user_email != "" ? 1 : 0
#  depends_on = [databricks_mws_workspaces.this]
#  provider = databricks.accounts
#  display_name = "admins"
# }
