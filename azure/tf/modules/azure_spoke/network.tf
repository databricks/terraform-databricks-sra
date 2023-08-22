resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "this" {
  name                = "${var.project_name}-vnet"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [var.spoke_vnet_address_space]
}

resource "azurerm_network_security_group" "this" {
  name                = "${var.project_name}-databricks-nsg"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet" "container" {
  name                 = "${var.project_name}-container"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name

  address_prefixes = [cidrsubnet(var.spoke_vnet_cidr, 2, 0)]

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
  name                 = "${var.project_name}-host"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name

  address_prefixes = [cidrsubnet(var.spoke_vnet_cidr, 2, 1)]

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
  name                 = "${var.project_name}-privatelink"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name

  address_prefixes = [cidrsubnet(var.spoke_vnet_cidr, 2, 2)] # do some math to make this a fixed small size
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

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = format("from-%s-to-%s-peer", azurerm_virtual_network.this.name, var.hub_vnet_name)
  resource_group_name       = azurerm_resource_group.this.name
  virtual_network_name      = azurerm_virtual_network.this.name
  remote_virtual_network_id = var.hub_vnet_id
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = format("from-%s-to-%s-peer", var.hub_vnet_name, azurerm_virtual_network.this.name)
  resource_group_name       = var.hub_resource_group_name
  virtual_network_name      = var.hub_vnet_name
  remote_virtual_network_id = azurerm_virtual_network.this.id
}

resource "azurerm_subnet_route_table_association" "host" {
  subnet_id      = azurerm_subnet.host.id
  route_table_id = var.route_table_id

  depends_on = [azurerm_virtual_network_peering.hub_to_spoke, azurerm_virtual_network_peering.spoke_to_hub]
}

resource "azurerm_subnet_route_table_association" "container" {
  subnet_id      = azurerm_subnet.container.id
  route_table_id = var.route_table_id

  depends_on = [azurerm_virtual_network_peering.hub_to_spoke, azurerm_virtual_network_peering.spoke_to_hub]
}
