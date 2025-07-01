# The value of the "workspace_url" property represents the URL of the Databricks workspace
output "workspace_url" {
  description = "The URL of the Databricks workspace, used to access the Databricks environment."
  value       = azurerm_databricks_workspace.this.workspace_url
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

output "ipgroup_cidrs" {
  description = "A map containing the CIDRs for the host and container IP groups, used for network segmentation in Azure."
  value = {
    ipgroup_host_cidr      = azurerm_ip_group_cidr.host.cidr
    ipgroup_container_cidr = azurerm_ip_group_cidr.container.cidr
  }
}

output "resource_group_name" {
  description = "Name of deployed resource group"
  value       = azurerm_resource_group.this.name
}

output "dbfs_storage_account_id" {
  description = "Resource ID of the DBFS storage account"
  value       = data.azurerm_storage_account.dbfs.id
}

output "dns_zone_ids" {
  description = "Private DNS Zone IDs"
  value = {
    dfs     = var.boolean_create_private_dbfs ? azurerm_private_dns_zone.dbfs_dfs[0].id : "",
    blob    = var.boolean_create_private_dbfs ? azurerm_private_dns_zone.dbfs_blob[0].id : "",
    backend = azurerm_private_dns_zone.backend.id
  }
}

output "subnet_ids" {
  description = "Subnet IDs"
  value = {
    host        = azurerm_subnet.host.id
    container   = azurerm_subnet.container.id
    privatelink = azurerm_subnet.privatelink.id
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
