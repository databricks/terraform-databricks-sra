output "metastore_id" {
  description = "Metastore ID."
  value       = var.metastore_exists ? data.databricks_metastore.this[0].id : databricks_metastore.this[0].id
}