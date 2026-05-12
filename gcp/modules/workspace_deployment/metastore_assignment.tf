resource "databricks_metastore_assignment" "this" {
  count        = var.regional_metastore_id != "" ? 1 : 0
  provider     = databricks.accounts
  workspace_id = databricks_mws_workspaces.this.workspace_id
  metastore_id = var.regional_metastore_id
}

# Set the workspace's default namespace (default catalog) to an existing
# catalog in the assigned metastore. The module does not create the catalog —
# it must already exist. Skipped when default_catalog_name is empty, which
# leaves the workspace at whatever default Databricks assigns.
resource "databricks_default_namespace_setting" "this" {
  count    = (var.regional_metastore_id != "" && var.default_catalog_name != "") ? 1 : 0
  provider = databricks.workspace

  namespace {
    value = var.default_catalog_name
  }

  depends_on = [databricks_metastore_assignment.this]
}
