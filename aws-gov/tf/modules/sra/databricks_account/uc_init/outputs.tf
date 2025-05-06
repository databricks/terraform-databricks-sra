output "metastore_id" {
  value = var.metastore_exists ? data.databricks_metastore.this[0].id : databricks_metastore.this[0].id
}