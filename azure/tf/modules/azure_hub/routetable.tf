resource "azurerm_ip_group" "this" {
  name                = "${local.prefix}-databricks-subnets"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  lifecycle {
    ignore_changes = [cidrs]
  }
}

# Create an Azure route table resource
resource "azurerm_route_table" "this" {
  name                = "${local.prefix}-route-table"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

# Create a route in the route table to direct traffic to the firewall
resource "azurerm_route" "firewall_route" {
  count = var.is_firewall_enabled ? 1 : 0

  name                   = "to-firewall"
  resource_group_name    = azurerm_resource_group.this.name
  route_table_name       = azurerm_route_table.this.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.this[0].ip_configuration.0.private_ip_address
}
