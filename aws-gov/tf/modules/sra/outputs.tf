output "databricks_host" {
  description = "Host name of the workspace URL"
  value = module.databricks_mws_workspace.workspace_url
}