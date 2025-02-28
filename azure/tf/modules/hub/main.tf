<<<<<<< HEAD
<<<<<<< HEAD
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
=======
# Generate a random string for naming resources
<<<<<<< HEAD
resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
>>>>>>> 60cc2bc (remove redundant module naming)
=======
# resource "random_string" "naming" {
#   special = false
#   upper   = false
#   length  = 6
# }

=======
>>>>>>> 2531551 (chore: Remove commented code)
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.1"
  suffix  = [var.resource_suffix]
>>>>>>> 900395d (naming)
}

# Create the hub resource group
resource "azurerm_resource_group" "this" {
<<<<<<< HEAD
  name     = module.naming.resource_group.name
  location = var.location

  tags = var.tags
=======
  name     = var.hub_resource_group_name
  location = var.location
  tags     = var.tags
>>>>>>> 60cc2bc (remove redundant module naming)
}

# Create the hub virtual network
resource "azurerm_virtual_network" "this" {
<<<<<<< HEAD
<<<<<<< HEAD
  name                = module.naming.virtual_network.name
=======
  name                = var.hub_vnet_name
>>>>>>> 60cc2bc (remove redundant module naming)
=======
  name                = module.naming.virtual_network.name
>>>>>>> bba9fc9 (remove vnet naming option in the hub to standardize approach, add example tfvars)
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [var.hub_vnet_cidr]

<<<<<<< HEAD
<<<<<<< HEAD
  tags = var.tags
=======
  lifecycle {
    ignore_changes = [tags]
  }
>>>>>>> 60cc2bc (remove redundant module naming)
=======
  tags = var.tags
>>>>>>> 3603a0f (fix: Remove ignore_changes on all tags and pass var.tags as tags argument)
}

# Create the privatelink subnet
resource "azurerm_subnet" "privatelink" {
  name                 = "hub-privatelink"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name

<<<<<<< HEAD
<<<<<<< HEAD
  address_prefixes = [var.subnet_map["privatelink"]]
=======
  address_prefixes = [local.subnet_map["privatelink"]]
>>>>>>> 60cc2bc (remove redundant module naming)
=======
  address_prefixes = [var.subnet_map["privatelink"]]
>>>>>>> 8d44021 (serverless and classic compute working)
}
