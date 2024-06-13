// Metastore Assignment

data "databricks_metastore" "this" {
  region = var.region
}

resource "databricks_metastore_assignment" "default_metastore" {
  workspace_id         = var.workspace_id
  metastore_id         = var.metastore_id == null ? data.databricks_metastore.this.id : var.metastore_id
  default_catalog_name = "hive_metastore"
}