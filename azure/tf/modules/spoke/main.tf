# Generate a random string for dbfsnaming
resource "random_string" "dbfsnaming" {
  special = false
  upper   = false
  length  = 13
}

# Define subnets using cidrsubnet function
locals {
  subnets = {
    "host" : cidrsubnet(var.vnet_cidr, 2, 0)
    "container" : cidrsubnet(var.vnet_cidr, 2, 1)
    "privatelink" : cidrsubnet(var.vnet_cidr, 2, 2)
  }

  # Generate a random string for dbfs_name
  dbfs_name = join("", ["dbstorage", random_string.dbfsnaming.result])
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.1"
  suffix  = [var.resource_suffix]
}


# Create a resource group
resource "azurerm_resource_group" "this" {
  name     = module.naming.resource_group
  location = var.location

  tags = var.tags
}

# Create a virtual network
resource "azurerm_virtual_network" "this" {
  name                = module.naming.virtual_network
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [var.vnet_cidr]

  tags = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

# Create a network security group
resource "azurerm_network_security_group" "this" {
  name                = module.naming.network_security_group
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  tags = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

# Associate the container subnet with the network security group
resource "azurerm_subnet_network_security_group_association" "container" {
  subnet_id                 = azurerm_subnet.container.id
  network_security_group_id = azurerm_network_security_group.this.id
}

# Associate the host subnet with the network security group
resource "azurerm_subnet_network_security_group_association" "host" {
  subnet_id                 = azurerm_subnet.host.id
  network_security_group_id = azurerm_network_security_group.this.id
}

# Create the container subnet
resource "azurerm_subnet" "container" {
  name                 = "${module.naming.subnet}-container"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name

  address_prefixes = [local.subnets["container"]]

  delegation {
    name = "databricks-container-subnet-delegation"

    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
      ]
    }
  }
}

# Create the host subnet
resource "azurerm_subnet" "host" {
  name                 = "${module.naming.subnet}-host"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name

  address_prefixes = [local.subnets["host"]]

  delegation {
    name = "databricks-host-subnet-delegation"

    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
      ]
    }
  }
}

# Create the privatelink subnet
resource "azurerm_subnet" "privatelink" {
  name                 = "${module.naming.subnet}-pl"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name

  address_prefixes = [local.subnets["privatelink"]]
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
  resource_group_name         = azurerm_resource_group.this.name
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
  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.this.name
}
