output "workspace_url" {
  description = "Workspace URL."
  value       = databricks_mws_workspaces.workspace.workspace_url
}

output "workspace_id" {
  description = "Workspace ID."
  value       = databricks_mws_workspaces.workspace.workspace_id
}