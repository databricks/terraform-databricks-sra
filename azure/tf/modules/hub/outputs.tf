output "dns_zone_ids" {
  description = "Private DNS Zone IDs"
  value = {
    backend = azurerm_private_dns_zone.backend.id
    dfs     = var.boolean_create_private_dbfs ? azurerm_private_dns_zone.dbfs_dfs[0].id : ""
    blob    = var.boolean_create_private_dbfs ? azurerm_private_dns_zone.dbfs_blob[0].id : ""
  }
}

output "subnet_ids" {
  description = "Subnet IDs for WEBAUTH workspace"
  value = {
    host        = azurerm_subnet.webauth_host.id
    container   = azurerm_subnet.webauth_container.id
    privatelink = azurerm_subnet.privatelink.id
  }
}

output "subnet_names" {
  description = "Subnet names for WEBAUTH workspace"
  value = {
    host        = azurerm_subnet.webauth_host.name
    container   = azurerm_subnet.webauth_container.name
    privatelink = azurerm_subnet.privatelink.name
  }
}

output "public_subnet_network_security_group_association_id" {
  description = "NSG association ID for host subnet"
  value       = azurerm_subnet_network_security_group_association.webauth_host.id
}

output "private_subnet_network_security_group_association_id" {
  description = "NSG association ID for container subnet"
  value       = azurerm_subnet_network_security_group_association.webauth_container.id
}

output "resource_group_name" {
  description = "Hub resource group name"
  value       = azurerm_resource_group.this.name
}

output "vnet_name" {
  description = "Hub VNet name"
  value       = azurerm_virtual_network.this.name
}

output "vnet_id" {
  description = "Hub VNet ID"
  value       = azurerm_virtual_network.this.id
}

output "ncc_id" {
  description = "NCC ID"
  value       = databricks_mws_network_connectivity_config.this.network_connectivity_config_id
}

output "ncc_name" {
  description = "NCC name"
  value       = databricks_mws_network_connectivity_config.this.name
}

output "network_policy_id" {
  description = "Restrictive network policy ID for spokes"
  value       = databricks_account_network_policy.restrictive_network_policy.network_policy_id
}

output "hub_network_policy_id" {
  description = "Hub network policy ID for WEBAUTH workspace"
  value       = databricks_account_network_policy.hub_policy.network_policy_id
}

output "resource_suffix" {
  description = "Resource suffix"
  value       = var.resource_suffix
}

output "tags" {
  description = "Tags"
  value       = var.tags
}

output "route_table_id" {
  description = "Route table ID"
  value       = azurerm_route_table.this.id
}

output "ipgroup_id" {
  description = "IP group ID"
  value       = azurerm_ip_group.this.id
}

output "metastore_id" {
  value       = length(databricks_metastore.this) > 0 ? databricks_metastore.this[0].id : null
  description = "The unique ID of the Databricks Metastore."
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
