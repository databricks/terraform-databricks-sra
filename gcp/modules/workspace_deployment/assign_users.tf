# Assign var.resource_owner as a workspace admin.
#
# Gated by:
#  - var.resource_owner must be set (module callers opt in)
#  - var.skip_user_lookup must be false (used to bypass the data source during destroy,
#    when the user may no longer exist in the account).

data "databricks_user" "resource_owner" {
  count      = (var.resource_owner != "" && !var.skip_user_lookup) ? 1 : 0
  provider   = databricks.accounts
  user_name  = var.resource_owner
  depends_on = [time_sleep.wait_for_workspace_apis]
}

resource "databricks_mws_permission_assignment" "resource_owner_admin" {
  count        = (var.resource_owner != "" && !var.skip_user_lookup) ? 1 : 0
  provider     = databricks.accounts
  workspace_id = databricks_mws_workspaces.this.workspace_id
  principal_id = data.databricks_user.resource_owner[0].id
  permissions  = ["ADMIN"]
  depends_on   = [time_sleep.wait_for_workspace_apis]
}

# Optional: IP access list configuration.
# Uncomment to enable IP-based access restrictions on the workspace.
#
# resource "databricks_ip_access_list" "allowed_list" {
#   provider     = databricks.workspace
#   label        = "allow_in"
#   list_type    = "ALLOW"
#   ip_addresses = var.ip_addresses
#   depends_on   = [databricks_mws_workspaces.this]
# }
