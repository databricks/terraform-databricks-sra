module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~>0.4"
  suffix  = [var.resource_suffix]
}

# Create the hub resource group
resource "azurerm_resource_group" "this" {
  name     = module.naming.resource_group.name
  location = var.location
  tags     = var.tags
}

# Create the hub virtual network
resource "azurerm_virtual_network" "this" {
  name                = module.naming.virtual_network.name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [var.hub_vnet_cidr]
  tags                = var.tags
}

# Create subnets for WEBAUTH workspace
resource "azurerm_subnet" "webauth_host" {
  name                 = "webauth-host"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.subnet_map["webauth-host"]]

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

resource "azurerm_subnet" "webauth_container" {
  name                 = "webauth-container"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.subnet_map["webauth-container"]]

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

resource "azurerm_subnet" "privatelink" {
  name                 = "hub-privatelink"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.subnet_map["privatelink"]]
}

# Create NSG for WEBAUTH workspace
resource "azurerm_network_security_group" "webauth" {
  name                = "webauth-nsg"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
}

# NSG associations
resource "azurerm_subnet_network_security_group_association" "webauth_host" {
  subnet_id                 = azurerm_subnet.webauth_host.id
  network_security_group_id = azurerm_network_security_group.webauth.id
}

resource "azurerm_subnet_network_security_group_association" "webauth_container" {
  subnet_id                 = azurerm_subnet.webauth_container.id
  network_security_group_id = azurerm_network_security_group.webauth.id
}

# Route table association for webauth host subnet
resource "azurerm_subnet_route_table_association" "webauth_host" {
  subnet_id      = azurerm_subnet.webauth_host.id
  route_table_id = azurerm_route_table.this.id
}

# IP group CIDR for webauth host subnet
resource "azurerm_ip_group_cidr" "webauth_host" {
  ip_group_id = azurerm_ip_group.this.id
  cidr        = var.subnet_map["webauth-host"]
}
