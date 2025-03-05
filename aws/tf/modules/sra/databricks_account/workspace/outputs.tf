output "workspace_url" {
<<<<<<< HEAD
  description = "Workspace URL."
  value       = databricks_mws_workspaces.workspace.workspace_url
}

output "workspace_id" {
  description = "Workspace ID."
  value       = databricks_mws_workspaces.workspace.workspace_id
=======
  value = length(databricks_mws_workspaces.this_with_deployment_name) > 0 ? databricks_mws_workspaces.this_with_deployment_name[0].workspace_url : databricks_mws_workspaces.this_without_deployment_name[0].workspace_url
}

output "workspace_id" {
  value = length(databricks_mws_workspaces.this_with_deployment_name) > 0 ? databricks_mws_workspaces.this_with_deployment_name[0].workspace_id : databricks_mws_workspaces.this_without_deployment_name[0].workspace_id
>>>>>>> d598b99 (tf linting, sat integration, audit logs reintegration, additional resource for deployment name, and readme update)
}
