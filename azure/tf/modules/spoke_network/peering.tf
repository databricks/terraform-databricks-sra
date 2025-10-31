# Create a virtual network peering from the spoke network to the hub network
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = format("from-%s-to-%s-peer", azurerm_virtual_network.this.name, var.hub_vnet_name)
  resource_group_name       = azurerm_resource_group.this.name
  virtual_network_name      = azurerm_virtual_network.this.name
  remote_virtual_network_id = var.hub_vnet_id
}

# Create a virtual network peering from the hub network to the spoke network
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = format("from-%s-to-%s-peer", var.hub_vnet_name, azurerm_virtual_network.this.name)
  resource_group_name       = var.hub_resource_group_name
  virtual_network_name      = var.hub_vnet_name
  remote_virtual_network_id = azurerm_virtual_network.this.id
}

# Associate the route table with the host subnet
resource "azurerm_subnet_route_table_association" "host" {
  subnet_id      = azurerm_subnet.host.id
  route_table_id = var.route_table_id

  depends_on = [azurerm_virtual_network_peering.hub_to_spoke, azurerm_virtual_network_peering.spoke_to_hub]
}

# Associate the route table with the container subnet
resource "azurerm_subnet_route_table_association" "container" {
  subnet_id      = azurerm_subnet.container.id
  route_table_id = var.route_table_id

  depends_on = [azurerm_virtual_network_peering.hub_to_spoke, azurerm_virtual_network_peering.spoke_to_hub]
}

# Assign the host subnet CIDR to the IP group
resource "azurerm_ip_group_cidr" "host" {
  ip_group_id = var.ipgroup_id
  cidr        = local.subnets["host"]
}

# Assign the container subnet CIDR to the IP group
resource "azurerm_ip_group_cidr" "container" {
  ip_group_id = var.ipgroup_id
  cidr        = local.subnets["container"]
}
