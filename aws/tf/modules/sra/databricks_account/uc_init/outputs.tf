output "metastore_id" {
  description = "Metastore ID."
<<<<<<< HEAD
<<<<<<< HEAD
  value       = var.metastore_exists ? data.databricks_metastore.this[0].id : databricks_metastore.this[0].id
=======
  value = var.metastore_exists ? data.databricks_metastore.this[0].id : databricks_metastore.this[0].id
>>>>>>> 2615071 (further formatting and linting)
=======
  value       = var.metastore_exists ? data.databricks_metastore.this[0].id : databricks_metastore.this[0].id
>>>>>>> ecbeb76 (adding required provider versions)
}