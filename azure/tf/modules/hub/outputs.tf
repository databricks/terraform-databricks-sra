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

# Network outputs - exposing internal hub_network module outputs
output "vnet_id" {
  description = "Hub Virtual Network ID"
  value       = module.hub_network.vnet_id
}

output "subnet_ids" {
  description = "Hub subnet IDs"
  value       = module.hub_network.subnet_ids
}

output "dns_zone_ids" {
  description = "Hub Private DNS Zone IDs"
  value       = module.hub_network.dns_zone_ids
}

output "network_configuration" {
  description = "Network configuration for workspace deployment"
  value       = module.hub_network.network_configuration
}

output "network_cidr_blocks" {
  description = "CIDR allocations in hub network"
  value       = module.hub_network.network_cidr_blocks
}
