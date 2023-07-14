locals {
  title_cased_location = title(var.location)
  service_tags = {
    "databricks" : "AzureDatabricks",
    "sql" : "Sql.${local.title_cased_location}",
    "storage" : "Storage.${local.title_cased_location}",
    "eventhub" : "EventHub.${local.title_cased_location}"
  }
}

data "azurerm_virtual_network" "hub" {
  name                = var.hub_vnet_name
  resource_group_name = var.hub_resource_group_name
}

resource "azurerm_resource_group" "this" {
  name     = var.spoke_resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "this" {
  name                = "spoke-vnet-${var.project_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [var.spoke_vnet_address_space]
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = format("from-%s-to-%s-peer", azurerm_virtual_network.this.name, var.hub_vnet_name)
  resource_group_name       = azurerm_resource_group.this.name
  virtual_network_name      = azurerm_virtual_network.this.name
  remote_virtual_network_id = data.azurerm_virtual_network.hub.id
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = format("from-%s-to-%s-peer", var.hub_vnet_name, azurerm_virtual_network.this.name)
  resource_group_name       = var.hub_resource_group_name
  virtual_network_name      = var.hub_vnet_name
  remote_virtual_network_id = azurerm_virtual_network.this.id
}

resource "azurerm_network_security_group" "this" {
  name                = "databricks-nsg-${var.project_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_route_table" "this" {
  name                = "route-table-${var.project_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_route" "firewall_route" {
  name                   = "to-firewall"
  resource_group_name    = azurerm_resource_group.this.name
  route_table_name       = azurerm_route_table.this.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.firewall_private_ip
}

resource "azurerm_route" "service_tags" {
  for_each            = local.service_tags
  name                = each.key
  resource_group_name = azurerm_resource_group.this.name
  route_table_name    = azurerm_route_table.this.name
  address_prefix      = each.value
  next_hop_type       = "Internet"
}
