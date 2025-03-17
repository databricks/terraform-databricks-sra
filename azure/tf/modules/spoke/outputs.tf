locals {
  uc_abfss_url       = var.is_unity_catalog_enabled ? "abfss://${azurerm_storage_container.unity_catalog[0].name}@${azurerm_storage_account.unity_catalog[0].primary_dfs_host}/unitycatalog" : ""
  uc_credential_name = var.is_unity_catalog_enabled ? databricks_storage_credential.unity_catalog[0].name : ""
}

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

output "uc_abfss_url" {
  description = "URL for Unity Catalog storage account for creating an external location"
  value       = local.uc_abfss_url
}

output "uc_crendential_name" {
  description = "Name of the storage credential created for UC"
  value       = local.uc_credential_name
}
