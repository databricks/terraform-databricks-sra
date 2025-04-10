# Generate a random string for dbfsnaming
resource "random_string" "dbfsnaming" {
  special = false
  upper   = false
  length  = 13
}

# Define subnets using cidrsubnet function
locals {
  # Generate a random string for dbfs_name
  dbfs_name       = join("", ["dbstorage", random_string.dbfsnaming.result])
  managed_rg_name = join("", [module.naming.resource_group.name_unique, "adbmanaged"])
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~>0.4"
  suffix  = [var.resource_suffix]
}

# Create the hub resource group
resource "azurerm_resource_group" "this" {
  name     = module.naming.resource_group.name
  location = var.location

  tags = var.tags
}

# Create the hub virtual network
resource "azurerm_virtual_network" "this" {
  name                = module.naming.virtual_network.name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [var.hub_vnet_cidr]

  tags = var.tags
}

# Create the privatelink subnet
resource "azurerm_subnet" "privatelink" {
  name                 = "hub-privatelink"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name

  address_prefixes = [var.subnet_map["privatelink"]]
}
