output "catalog_name" {
  description = "Name of the catalog created for the workspace."
  value       = module.unity_catalog_catalog_creation.catalog_name
}

output "metastore_id" {
  description = "ID of the Unity Catalog metastore assigned to the workspace, whether created by this deployment or pre-existing."
  value       = module.unity_catalog_metastore_creation.metastore_id
}

output "network_connectivity_configuration_id" {
  description = "ID of the network connectivity configuration (NCC) that governs serverless egress for the workspace."
  value       = module.network_connectivity_configuration.ncc_id
}

output "network_policy_id" {
  description = "ID of the account network policy attached to the workspace."
  value       = module.network_policy.network_policy_id
}

output "vpc_id" {
  description = "ID of the classic compute plane VPC (created or custom). Null for SERVERLESS workspaces, which have no customer VPC."
  value       = local.is_serverless ? null : (var.custom_vpc_id != null ? var.custom_vpc_id : module.vpc[0].vpc_id)
}

output "workspace_host" {
  description = "URL of the workspace."
  value       = module.databricks_mws_workspace.workspace_url
}

output "workspace_id" {
  description = "ID of the workspace."
  value       = module.databricks_mws_workspace.workspace_id
}
