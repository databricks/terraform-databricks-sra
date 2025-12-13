# Create virtual network peerings from this network to it's peers
resource "azurerm_virtual_network_peering" "peers" {
  for_each = var.virtual_network_peerings

  name                      = each.value.name == "" ? "from-${azurerm_virtual_network.this.name}-to-${provider::azurerm::parse_resource_id(each.value.remote_virtual_network_id).resource_name}-peer" : each.value.name
  remote_virtual_network_id = each.value.remote_virtual_network_id
  resource_group_name       = azurerm_virtual_network.this.resource_group_name
  virtual_network_name      = azurerm_virtual_network.this.name
}
