locals {
  subnets = {
    "host" : cidrsubnet(var.vnet_cidr, 2, 0)
    "container" : cidrsubnet(var.vnet_cidr, 2, 1)
    "privatelink" : cidrsubnet(var.vnet_cidr, 2, 2)
  }
  dbfs_name = join("", ["dbstorage", random_string.dbfsnaming.result])
}

resource "random_string" "dbfsnaming" {
  special = false
  upper   = false
  length  = 13
}

resource "azurerm_resource_group" "this" {
  name     = "${var.prefix}-rg"
  location = var.location

  tags = var.tags
}

resource "azurerm_virtual_network" "this" {
  name                = "${var.prefix}-vnet"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [var.vnet_cidr]

  tags = var.tags
}

resource "azurerm_network_security_group" "this" {
  name                = "${var.prefix}-databricks-nsg"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "container" {
  subnet_id                 = azurerm_subnet.container.id
  network_security_group_id = azurerm_network_security_group.this.id
}

resource "azurerm_subnet_network_security_group_association" "host" {
  subnet_id                 = azurerm_subnet.host.id
  network_security_group_id = azurerm_network_security_group.this.id
}

resource "azurerm_subnet" "container" {
  name                 = "${var.prefix}-container"
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

resource "azurerm_subnet" "host" {
  name                 = "${var.prefix}-host"
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

resource "azurerm_subnet" "privatelink" {
  name                                      = "${var.prefix}-privatelink"
  resource_group_name                       = azurerm_resource_group.this.name
  virtual_network_name                      = azurerm_virtual_network.this.name
  private_endpoint_network_policies_enabled = false

  address_prefixes = [local.subnets["privatelink"]]
}

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
