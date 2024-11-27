// Metastore Assignment

resource "databricks_metastore_assignment" "default_metastore" {
  workspace_id = var.workspace_id
  metastore_id = var.metastore_id
}