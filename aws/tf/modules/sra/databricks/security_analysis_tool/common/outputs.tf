output "secret_scope_id" {
  value       = databricks_secret_scope.sat.id
  description = "ID of the created secret scope to add more secrets if necessary"
}
