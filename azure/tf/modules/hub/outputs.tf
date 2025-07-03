output "firewall_name" {
  value       = length(azurerm_firewall.this) > 0 ? azurerm_firewall.this[0].name : ""
  description = "The name of the Azure Firewall resource."
}

output "ipgroup_id" {
  value       = azurerm_ip_group.this.id
  description = "The unique ID of the Azure IP Group."
}

output "route_table_id" {
  value       = azurerm_route_table.this.id
  description = "The unique ID of the Azure Route Table."
}

output "key_vault_id" {
  value       = length(azurerm_key_vault.this) > 0 ? azurerm_key_vault.this[0].id : null
  description = "The ID of the Azure Key Vault, if created. Returns null if no Key Vault is created."
}

output "managed_disk_key_id" {
  value       = length(azurerm_key_vault_key.managed_disk) > 0 ? azurerm_key_vault_key.managed_disk[0].id : null
  description = "The ID of the Key Vault key used for managed disks, if available. Returns null if not created."
}

output "managed_services_key_id" {
  value       = length(azurerm_key_vault_key.managed_services) > 0 ? azurerm_key_vault_key.managed_services[0].id : null
  description = "The ID of the Key Vault key used for managed services, if available. Returns null if not created."
}

output "vnet_id" {
  value       = azurerm_virtual_network.this.id
  description = "The unique ID of the Azure Virtual Network."
}

output "vnet_name" {
  value       = azurerm_virtual_network.this.name
  description = "The name of the Azure Virtual Network."
}

output "metastore_id" {
  value       = length(databricks_metastore.this) > 0 ? databricks_metastore.this[0].id : null
  description = "The unique ID of the Databricks Metastore."
}

output "is_unity_catalog_enabled" {
  value       = var.is_unity_catalog_enabled
  description = "If UC creation is enabled"
}

output "resource_group_name" {
  value       = azurerm_resource_group.this.name
  description = "The name of the Azure Resource Group."
}

output "private_link_info" {
  value = {
    dns_zone_id = azurerm_private_dns_zone.auth_front.id
    subnet_id   = azurerm_subnet.privatelink.id
  }
  description = "Information related to the Private Link, including DNS Zone ID and Subnet ID for Private Link connectivity."
}

output "dns_zone_ids" {
  description = "Private DNS Zone IDs"
  value = {
    dfs     = azurerm_private_dns_zone.dbfs_dfs[0].id,
    blob    = azurerm_private_dns_zone.dbfs_blob[0].id,
    backend = azurerm_private_dns_zone.auth_front.id
  }
}

output "ncc_id" {
  description = "NCC ID of this workspace"
  value       = databricks_mws_network_connectivity_config.this.network_connectivity_config_id
}

output "ncc_name" {
  description = "NCC name of this workspace"
  value       = databricks_mws_network_connectivity_config.this.name
}

output "subnet_ids" {
  description = "Subnet IDs"
  value = {
    host        = azurerm_subnet.host.id
    container   = azurerm_subnet.container.id
    privatelink = azurerm_subnet.privatelink.id
  }
}

output "tags" {
  description = "Tags used in hub"
  value       = var.tags
}

output "workspace_url" {
  description = "The URL of the Databricks workspace, used to access the Databricks environment."
  value       = null_resource.admin_wait.triggers.workspace_url
}

output "workspace_id" {
  value       = azurerm_databricks_workspace.webauth.workspace_id
  description = "Workspace ID of the created workspace, according to the Databricks account console"
}

output "resource_suffix" {
  description = "Resource suffix to use for naming down stream resources"
  value       = var.resource_suffix
}

output "network_policy_id" {
  description = "Network Policy ID"
  value       = databricks_account_network_policy.restrictive_network_policy.network_policy_id
}
