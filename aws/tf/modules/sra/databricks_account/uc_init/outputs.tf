output "metastore_id" {
  description = "Metastore ID."
<<<<<<< HEAD
  value       = var.metastore_exists ? data.databricks_metastore.this[0].id : databricks_metastore.this[0].id
=======
  value = var.metastore_exists ? data.databricks_metastore.this[0].id : databricks_metastore.this[0].id
>>>>>>> 2615071 (further formatting and linting)
}