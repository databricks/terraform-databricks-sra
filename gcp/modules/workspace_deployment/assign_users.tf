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

# Grant the provisioning service account (the identity the databricks.workspace
# provider authenticates as) workspace ADMIN. Without this, workspace-scoped API
# calls (workspace_conf, IP access list) fail with "Unauthorized access to Org"
# because creating the workspace at the account level does not by itself grant
# the creator workspace-level access.
data "databricks_user" "provisioner" {
  count      = (var.manage_workspace_settings && !var.serverless_workspace_deployment) ? 1 : 0
  provider   = databricks.accounts
  user_name  = var.databricks_google_service_account
  depends_on = [time_sleep.wait_for_workspace_apis]
}

resource "databricks_mws_permission_assignment" "provisioner_workspace_admin" {
  count        = (var.manage_workspace_settings && !var.serverless_workspace_deployment) ? 1 : 0
  provider     = databricks.accounts
  workspace_id = databricks_mws_workspaces.this.workspace_id
  principal_id = data.databricks_user.provisioner[0].id
  permissions  = ["ADMIN"]
  depends_on   = [time_sleep.wait_for_workspace_apis]
}

# Let the workspace-admin grant propagate before the workspace-scoped provider
# relies on it.
resource "time_sleep" "wait_for_workspace_admin" {
  count           = (var.manage_workspace_settings && !var.serverless_workspace_deployment) ? 1 : 0
  create_duration = "15s"
  depends_on      = [databricks_mws_permission_assignment.provisioner_workspace_admin]
}

# Workspace IP access list. This ALLOW list is created BEFORE enableIpAccessLists
# is turned on in databricks_workspace_conf, so enforcement never starts without
# an allow rule present (no lock-out). Default var.ip_addresses is ["0.0.0.0/0"]
# (allow all); set it to restrict access. Skipped for serverless workspaces.
resource "databricks_ip_access_list" "allowed_list" {
  count        = (var.manage_workspace_settings && !var.serverless_workspace_deployment) ? 1 : 0
  provider     = databricks.workspace
  label        = "allow_in"
  list_type    = "ALLOW"
  ip_addresses = var.ip_addresses
  depends_on   = [time_sleep.wait_for_workspace_admin]
}
