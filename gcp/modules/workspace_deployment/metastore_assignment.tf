
resource "databricks_metastore_assignment" "this" {
  provider = databricks.accounts
  workspace_id         = databricks_mws_workspaces.this.workspace_id
  metastore_id         = var.regional_metastore_id
  default_catalog_name = "default_catalog"
}