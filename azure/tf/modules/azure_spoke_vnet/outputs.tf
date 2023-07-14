output "rg_name" {
  value = azurerm_resource_group.this.name
}

output "vnet_name" {
  value = azurerm_virtual_network.this.name
}

output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "nsg_id" {
  value = azurerm_network_security_group.this.id
}

output "route_table_id" {
  value = azurerm_route_table.this.id
}
