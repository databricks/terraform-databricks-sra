output "workspace_url" {
<<<<<<< HEAD
<<<<<<< HEAD
  description = "Workspace URL."
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> 1f2d783 (fix deployment name, update log delivery, and linting)
  value       = databricks_mws_workspaces.workspace.workspace_url
}

output "workspace_id" {
  description = "Workspace ID."
  value       = databricks_mws_workspaces.workspace.workspace_id
<<<<<<< HEAD
=======
=======
  description = "Workspace URL."
>>>>>>> 2615071 (further formatting and linting)
  value = length(databricks_mws_workspaces.this_with_deployment_name) > 0 ? databricks_mws_workspaces.this_with_deployment_name[0].workspace_url : databricks_mws_workspaces.this_without_deployment_name[0].workspace_url
=======
  value       = length(databricks_mws_workspaces.this_with_deployment_name) > 0 ? databricks_mws_workspaces.this_with_deployment_name[0].workspace_url : databricks_mws_workspaces.this_without_deployment_name[0].workspace_url
>>>>>>> ecbeb76 (adding required provider versions)
}

output "workspace_id" {
  description = "Workspace ID."
<<<<<<< HEAD
  value = length(databricks_mws_workspaces.this_with_deployment_name) > 0 ? databricks_mws_workspaces.this_with_deployment_name[0].workspace_id : databricks_mws_workspaces.this_without_deployment_name[0].workspace_id
>>>>>>> d598b99 (tf linting, sat integration, audit logs reintegration, additional resource for deployment name, and readme update)
=======
  value       = length(databricks_mws_workspaces.this_with_deployment_name) > 0 ? databricks_mws_workspaces.this_with_deployment_name[0].workspace_id : databricks_mws_workspaces.this_without_deployment_name[0].workspace_id
>>>>>>> ecbeb76 (adding required provider versions)
=======
>>>>>>> 1f2d783 (fix deployment name, update log delivery, and linting)
}
