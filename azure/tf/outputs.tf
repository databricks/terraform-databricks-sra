output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "virtual_network_name" {
  value = azurerm_virtual_network.this.name
}

output "firewall_name" {
  value = azurerm_firewall.this.name
}

output "workspace_url" {
  value = module.spoke_databricks_workspace.workspace_url
}
