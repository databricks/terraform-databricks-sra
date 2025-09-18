
# data "google_client_config" "current" {
# }



# resource "databricks_user" "me" {
#  count = var.create_admin_user ? 1 : 0
#  depends_on = [databricks_metastore_assignment.this]
#  provider  = databricks.accounts
#  user_name = var.admin_user_email
# }

# data "databricks_user" "me" {
#  count = var.create_admin_user ? 0 : 1
#  depends_on = [databricks_metastore_assignment.this]
#  provider  = databricks.accounts
#  user_name = var.admin_user_email
# }

# resource "databricks_mws_permission_assignment" "allow_me_to_login" {
#   count = var.admin_user_email != "" ? 1 : 0
#   provider = databricks.accounts
#   workspace_id = databricks_mws_workspaces.this.workspace_id
#   principal_id = var.create_admin_user? databricks_user.me[0].id : data.databricks_user.me[0].id
#   permissions = ["ADMIN"]
#   depends_on = [databricks_user.me]
# }

# resource "databricks_group_member" "allow_me_to_login" {
#  count = var.admin_user_email != "" ? 1 : 0
#  depends_on = [databricks_mws_workspaces.this,databricks_metastore_assignment.this]

#  provider  = databricks.accounts
# #  workspace_id = databricks_mws_workspaces.this.workspace_id
#  group_id  = data.databricks_group.admins[0].id
#  member_id = databricks_user.me[0].id
# }


# resource "databricks_ip_access_list" "allowed-list" {
#   provider = databricks.workspace
#   label     = "allow_in"
#   list_type = "ALLOW"
#   ip_addresses = var.ip_addresses
  
# }
