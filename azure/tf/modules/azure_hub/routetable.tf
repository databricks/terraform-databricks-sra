# build route table here
resource "azurerm_route_table" "this" {
  name                = "hub-route-table"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_route" "firewall_route" {
  name                   = "to-firewall"
  resource_group_name    = azurerm_resource_group.this.name
  route_table_name       = azurerm_route_table.this.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.this.ip_configuration.0.private_ip_address
}

# Route through firewall instead?
# resource "azurerm_route" "service_tags" {
#   for_each            = local.service_tags
#   name                = each.key
#   resource_group_name = azurerm_resource_group.this.name
#   route_table_name    = azurerm_route_table.this.name
#   address_prefix      = each.value
#   next_hop_type       = "Internet"
# }
