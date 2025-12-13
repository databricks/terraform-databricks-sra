# The value of the "workspace_url" property represents the URL of the Databricks workspace
output "workspace_url" {
  description = "The URL of the Databricks workspace, used to access the Databricks environment."
  value       = null_resource.admin_wait.triggers.workspace_url
}

output "workspace_id" {
  value       = azurerm_databricks_workspace.this.workspace_id
  description = "Workspace ID of the created workspace, according to the Databricks account console"
}

output "id" {
  value       = azurerm_databricks_workspace.this.id
  description = "Azure ID of the created workspace"
}

output "workspace" {
  value       = azurerm_databricks_workspace.this
  description = "Full workspace object"
}

output "dbfs_storage_account_id" {
  description = "Resource ID of the DBFS storage account"
  value       = local.dbfs_sa_resource_id
}

output "dns_zone_ids" {
  description = "Private DNS Zone IDs"
  value       = var.dns_zone_ids
}

output "subnet_ids" {
  description = "Subnet IDs"
  value = {
    host        = var.network_configuration.public_subnet_id
    container   = var.network_configuration.private_subnet_id
    privatelink = var.network_configuration.private_endpoint_subnet_id
  }
}

output "ncc_id" {
  description = "NCC ID of this workspace"
  value       = var.ncc_id
}

output "ncc_name" {
  description = "NCC name of this workspace"
  value       = var.ncc_name
}

output "resource_suffix" {
  description = "Resource suffix to use for naming down stream resources"
  value       = var.resource_suffix
}

output "tags" {
  description = "Tags of this spoke"
  value       = var.tags
}

output "webauth_private_endpoint_id" {
  description = "ID of the webauth private endpoint, if created"
  value       = var.create_webauth_private_endpoint ? azurerm_private_endpoint.webauth[0].id : null
}

output "resource_group_name" {
  description = "Name of deployed resource group"
  value       = azurerm_databricks_workspace.this.resource_group_name
}
