# Define a variable to store the title-cased location
locals {
  title_cased_location = title(var.location)

  # Define a map to store service tags with their corresponding values
  service_tags = {
    "sql" : "Sql.${local.title_cased_location}",
    "storage" : "Storage.${local.title_cased_location}",
    "eventhub" : "EventHub.${local.title_cased_location}"
  }

  # Define a regular expression pattern to extract subscription ID and resource group from the resource group ID
  resource_regex = "/subscriptions/(.+)/resourceGroups/(.+)"

  # Extract the subscription ID using the regular expression pattern
  subscription_id = regex(local.resource_regex, azurerm_resource_group.this.id)[0]

  # Extract the resource group using the regular expression pattern
  resource_group = regex(local.resource_regex, azurerm_resource_group.this.id)[1]

  # Get the tenant ID from the current Azure client configuration
  tenant_id = data.azurerm_client_config.current.tenant_id

  # Generate a prefix for naming resources by combining the hub resource group name and a random string
  prefix = replace(replace(lower("${var.hub_resource_group_name}${random_string.naming.result}"), "rg", ""), "-", "")

  subnet_map = var.subnet_map
}

# Retrieve the current Azure client configuration
data "azurerm_client_config" "current" {}

# Generate a random string for naming resources
resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
}

# Create the hub resource group
resource "azurerm_resource_group" "this" {
  name     = var.hub_resource_group_name
  location = var.location
  tags     = var.tags
}

# Create the hub virtual network
resource "azurerm_virtual_network" "this" {
  name                = var.hub_vnet_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [var.hub_vnet_cidr]

  lifecycle {
    ignore_changes = [tags]
  }
}

# Create the privatelink subnet
resource "azurerm_subnet" "privatelink" {
  name                 = "hub-privatelink"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name

  address_prefixes = [local.subnet_map["privatelink"]]
}
