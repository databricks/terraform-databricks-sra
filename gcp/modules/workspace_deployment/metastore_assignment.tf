
resource "databricks_metastore_assignment" "this" {
  count = var.regional_metastore_id != "" ? 1 : 0
  provider = databricks.accounts
  workspace_id         = databricks_mws_workspaces.this.workspace_id
  metastore_id         = var.regional_metastore_id
  default_catalog_name = "default_catalog"
}