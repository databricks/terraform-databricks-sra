# Create an Azure route table resource
resource "azurerm_route_table" "this" {
  name                = "${local.prefix}-route-table"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
}

# Create a route in the route table to direct traffic to the firewall
resource "azurerm_route" "firewall_route" {
  name                   = "to-firewall"
  resource_group_name    = azurerm_resource_group.hub.name
  route_table_name       = azurerm_route_table.this.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.this.ip_configuration.0.private_ip_address
}
