locals {
  uc_abfss_url       = var.is_unity_catalog_enabled ? "abfss://${azurerm_storage_container.unity_catalog[0].name}@${azurerm_storage_account.unity_catalog[0].primary_dfs_host}/unitycatalog" : ""
  uc_credential_name = var.is_unity_catalog_enabled ? databricks_storage_credential.unity_catalog[0].name : ""
}

# The value of the "workspace_url" property represents the URL of the Databricks workspace
output "workspace_url" {
<<<<<<< HEAD
<<<<<<< HEAD
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
=======
  value       = azurerm_databricks_workspace.this.workspace_url
=======
>>>>>>> b87392d (including spoke rg name in outputs)
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
<<<<<<< HEAD
>>>>>>> 60cc2bc (remove redundant module naming)
=======
  description = "A map containing the CIDRs for the host and container IP groups, used for network segmentation in Azure."
>>>>>>> b87392d (including spoke rg name in outputs)
  value = {
    ipgroup_host_cidr      = azurerm_ip_group_cidr.host.cidr
    ipgroup_container_cidr = azurerm_ip_group_cidr.container.cidr
  }
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> b87392d (including spoke rg name in outputs)
}

output "resource_group_name" {
  description = "Name of deployed resource group"
  value       = azurerm_resource_group.this.name
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> 1942ef7 (feat(azure): Remove default storage from metastore)
}

output "dbfs_storage_account_id" {
  description = "Resource ID of the DBFS storage account"
  value       = data.azurerm_storage_account.dbfs.id
}

<<<<<<< HEAD
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
  value       = databricks_mws_network_connectivity_config.this.network_connectivity_config_id
}

output "resource_suffix" {
  description = "Resource suffix to use for naming down stream resources"
  value       = var.resource_suffix
}

output "tags" {
  description = "Tags of this spoke"
  value       = var.tags
=======
  description = "A map containing the CIDRs for the host and container IP groups, used for network segmentation in Azure."
>>>>>>> 60cc2bc (remove redundant module naming)
=======

>>>>>>> b87392d (including spoke rg name in outputs)
=======
output "uc_abfss_url" {
  description = "URL for Unity Catalog storage account for creating an external location"
  value       = local.uc_abfss_url
}

output "uc_crendential_name" {
  description = "Name of the storage credential created for UC"
  value       = local.uc_credential_name
>>>>>>> 1942ef7 (feat(azure): Remove default storage from metastore)
}
