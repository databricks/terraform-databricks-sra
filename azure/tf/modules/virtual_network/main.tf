# Define subnets using cidrsubnet function
locals {
  workspace_subnets = toset(["container", "host"])
  subnets = concat(
    var.workspace_subnets.create ? [
      for subnet in local.workspace_subnets :
      {
        name     = subnet,
        new_bits = var.workspace_subnets.new_bits
      }
    ] : [],
    var.private_link_subnet.create ? [
      {
        name     = "privatelink"
        new_bits = var.private_link_subnet.new_bits
      }
    ] : [],
    values(var.extra_subnets)
  )
}

module "subnet_addrs" {
  source  = "hashicorp/subnets/cidr"
  version = "~>1.0"

  base_cidr_block = var.vnet_cidr
  networks        = local.subnets
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~>0.4"
  suffix  = [var.resource_suffix]
}

# Create a virtual network
resource "azurerm_virtual_network" "this" {
  name                = module.naming.virtual_network.name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.vnet_cidr]

  tags = var.tags
}

# Create a network security group
resource "azurerm_network_security_group" "this" {
  name                = module.naming.network_security_group.name
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Create a network security rule for AAD
resource "azurerm_network_security_rule" "aad" {
  name                        = "AllowAAD"
  priority                    = 200
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "AzureActiveDirectory"
  resource_group_name         = azurerm_network_security_group.this.resource_group_name
  network_security_group_name = azurerm_network_security_group.this.name
}

# Create a network security rule for Azure Front Door
resource "azurerm_network_security_rule" "azfrontdoor" {
  name                        = "AllowAzureFrontDoor"
  priority                    = 201
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "AzureFrontDoor.Frontend"
  resource_group_name         = azurerm_network_security_group.this.resource_group_name
  network_security_group_name = azurerm_network_security_group.this.name
}
