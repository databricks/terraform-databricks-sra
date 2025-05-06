
data "google_client_openid_userinfo" "me" {
}

data "databricks_group" "admins" {
 depends_on   = [databricks_mws_workspaces.this]
 provider     = databricks.workspace
 display_name = "admins"
}
