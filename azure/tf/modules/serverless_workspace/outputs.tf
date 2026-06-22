output "workspace_url" {
  description = "The URL of the Databricks workspace. Gated behind the admin role assignment + metastore assignment so downstream provider aliases can rely on it."
  value       = null_resource.admin_wait.triggers.workspace_url
}

output "workspace_id" {
  value       = azapi_resource.this.output.properties.workspaceId
  description = "Workspace ID of the created workspace, according to the Databricks account console"
}

output "id" {
  value       = azapi_resource.this.id
  description = "Azure ID of the created workspace"
}

output "dns_zone_ids" {
  description = "Private DNS Zone IDs (passthrough from input) for downstream consumers"
  value       = var.dns_zone_ids
}

output "resource_suffix" {
  description = "Resource suffix to use for naming downstream resources"
  value       = var.resource_suffix
}

output "tags" {
  description = "Tags applied to resources in this module"
  value       = var.tags
}

output "webauth_private_endpoint_id" {
  description = "ID of the webauth (browser_authentication) private endpoint"
  value       = azurerm_private_endpoint.webauth.id
}

output "resource_group_name" {
  description = "Name of the resource group hosting this workspace"
  value       = var.resource_group_name
}
