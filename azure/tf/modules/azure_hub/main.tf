locals {
  title_cased_location = title(var.location)
  service_tags = {
    "sql" : "Sql.${local.title_cased_location}",
    "storage" : "Storage.${local.title_cased_location}",
    "eventhub" : "EventHub.${local.title_cased_location}"
  }
}

resource "azurerm_resource_group" "this" {
  name     = var.hub_resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "this" {
  name                = var.hub_vnet_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [var.hub_vnet_cidr]
}

