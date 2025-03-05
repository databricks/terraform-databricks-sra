output "workspace_url" {
  description = "Workspace URL."
  value       = length(databricks_mws_workspaces.this_with_deployment_name) > 0 ? databricks_mws_workspaces.this_with_deployment_name[0].workspace_url : databricks_mws_workspaces.this_without_deployment_name[0].workspace_url
}

output "workspace_id" {
  description = "Workspace ID."
  value       = length(databricks_mws_workspaces.this_with_deployment_name) > 0 ? databricks_mws_workspaces.this_with_deployment_name[0].workspace_id : databricks_mws_workspaces.this_without_deployment_name[0].workspace_id
}
