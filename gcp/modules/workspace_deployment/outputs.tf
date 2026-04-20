output "workspace_url" {
  description = "URL of the Databricks workspace"
  value       = databricks_mws_workspaces.this.workspace_url
}

output "workspace_id" {
  description = "Databricks workspace ID"
  value       = databricks_mws_workspaces.this.workspace_id
}

output "workspace_name" {
  description = "Name of the Databricks workspace"
  value       = databricks_mws_workspaces.this.workspace_name
}

output "region" {
  description = "GCP region where resources are deployed"
  value       = var.google_region
}

# Backward-compatible alias for the workspace URL.
output "databricks_host" {
  description = "DEPRECATED: use workspace_url instead. Kept for backward compatibility."
  value       = databricks_mws_workspaces.this.workspace_url
}

output "deployment_suffix" {
  description = "Suffix applied to resource names (either derived from deployment_id or random)."
  value       = local.deployment_suffix
}
