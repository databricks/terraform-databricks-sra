output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "virtual_network_name" {
  value = azurerm_virtual_network.this.name
}

output "firewall_name" {
  value = azurerm_firewall.this.name
}

output "firewall_public_ip_address" {
  value = azurerm_public_ip.this.ip_address
}

output "route_table_id" {
  value = azurerm_route_table.this.id
}

