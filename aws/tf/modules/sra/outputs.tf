output "workspace_url" {
  value = module.databricks_mws_workspace.workspace_url
}

output "workspace_id" {
  value = module.databricks_mws_workspace.workspace_id
}

output "service_principal_id" {
  value = module.service_principal.service_principal_id
}
