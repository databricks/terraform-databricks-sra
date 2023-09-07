locals {
  title_cased_location = title(var.location)
  service_tags = {
    "sql" : "Sql.${local.title_cased_location}",
    "storage" : "Storage.${local.title_cased_location}",
    "eventhub" : "EventHub.${local.title_cased_location}"
  }
  resource_regex  = "/subscriptions/(.+)/resourceGroups/(.+)"
  subscription_id = regex(local.resource_regex, azurerm_resource_group.hub.id)[0]
  resource_group  = regex(local.resource_regex, azurerm_resource_group.hub.id)[1]
  tenant_id       = data.azurerm_client_config.current.tenant_id
  prefix          = replace(replace(lower("${var.hub_resource_group_name}${random_string.naming.result}"), "rg", ""), "-", "")
  hub_cidr_prefix = split("/", var.hub_vnet_cidr)[1]
  subnets = {
    "firewall" : cidrsubnet(var.hub_vnet_cidr, 26 - local.hub_cidr_prefix, 0)
    "webauth-host" : cidrsubnet(var.hub_vnet_cidr, 26 - local.hub_cidr_prefix, 1)
    "webauth-container" : cidrsubnet(var.hub_vnet_cidr, 26 - local.hub_cidr_prefix, 2)
    "privatelink" : cidrsubnet(var.hub_vnet_cidr, 24 - local.hub_cidr_prefix, 0)
  }
}

data "azurerm_client_config" "current" {}

resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
}

resource "azurerm_resource_group" "hub" {
  name     = var.hub_resource_group_name
  location = var.location
}

resource "azurerm_resource_group" "webauth" {
  name     = "${var.location}-webauthrg"
  location = var.location
}

resource "azurerm_virtual_network" "this" {
  name                = var.hub_vnet_name
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  address_space       = [var.hub_vnet_cidr]
}

resource "azurerm_subnet" "privatelink" {
  name                 = "hub-privatelink"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.this.name

  address_prefixes = [local.subnets["privatelink"]]
}
