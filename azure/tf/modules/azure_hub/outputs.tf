output "firewall_name" {
  value = azurerm_firewall.this.name
}

output "ipgroup_id" {
  value = azurerm_ip_group.this.id
}

output "route_table_id" {
  value = azurerm_route_table.this.id
}

output "key_vault_id" {
  value = azurerm_key_vault.this.id
}

output "managed_disk_key_id" {
  value = azurerm_key_vault_key.managed_disk.id
}

output "managed_services_key_id" {
  value = azurerm_key_vault_key.managed_services.id
}

output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "vnet_name" {
  value = azurerm_virtual_network.this.name
}

output "metastore_id" {
  value = databricks_metastore.this.id
}

output "resource_group_name" {
  value = azurerm_resource_group.hub.name
}
