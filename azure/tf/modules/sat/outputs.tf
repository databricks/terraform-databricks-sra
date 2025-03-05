output "service_principal_id" {
  value       = databricks_service_principal.sp.id
  description = "ID of the Databricks Service Principal"
}
