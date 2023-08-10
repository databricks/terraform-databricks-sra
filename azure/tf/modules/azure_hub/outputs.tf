output "firewall_name" {
  value = azurerm_firewall.this.name
}

output "firewall_public_ip_address" {
  value = azurerm_public_ip.this.ip_address
}

output "route_table_id" {
  value = azurerm_route_table.this.id
}

output "hub_info" {
  value = {
    rg_name   = azurerm_resource_group.this.name
    vnet_name = azurerm_virtual_network.this.name
    vnet_id   = azurerm_virtual_network.this.id
  }
}

