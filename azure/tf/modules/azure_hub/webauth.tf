# TODO: Need to move resource group to match the vnet - it doesn't like them being separate
resource "azurerm_subnet" "host" {
  name                 = "webauth-host"
  resource_group_name  = azurerm_resource_group.webauth.name
  virtual_network_name = azurerm_virtual_network.this.name

  address_prefixes = [local.subnets["webauth-host"]]

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

resource "azurerm_subnet" "container" {
  name                 = "webauth-container"
  resource_group_name  = azurerm_resource_group.webauth.name
  virtual_network_name = azurerm_virtual_network.this.name

  address_prefixes = [local.subnets["webauth-container"]]

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


resource "azurerm_network_security_group" "webauth" {
  name                = "webauth-nsg"
  location            = azurerm_resource_group.webauth.location
  resource_group_name = azurerm_resource_group.webauth.name
}

resource "azurerm_subnet_network_security_group_association" "container" {
  subnet_id                 = azurerm_subnet.container.id
  network_security_group_id = azurerm_network_security_group.webauth.id
}

resource "azurerm_subnet_network_security_group_association" "host" {
  subnet_id                 = azurerm_subnet.host.id
  network_security_group_id = azurerm_network_security_group.webauth.id
}

resource "azurerm_databricks_workspace" "webauth" {
  name                                  = join("_", ["WEB_AUTH_DO_NOT_DELETE", upper(azurerm_resource_group.webauth.location)])
  resource_group_name                   = azurerm_resource_group.webauth.name
  location                              = azurerm_resource_group.webauth.location
  sku                                   = "premium"
  public_network_access_enabled         = false
  network_security_group_rules_required = "NoAzureDatabricksRules"

  custom_parameters {
    no_public_ip                                         = true
    virtual_network_id                                   = azurerm_virtual_network.this.id
    private_subnet_name                                  = azurerm_subnet.container.name
    public_subnet_name                                   = azurerm_subnet.host.name
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.container.id
    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.host.id
  }

  tags = var.tags
}

resource "azurerm_management_lock" "webauth" {
  name       = "webauth-do-not-delete"
  scope      = azurerm_databricks_workspace.webauth.id
  lock_level = "CanNotDelete"
  notes      = "This lock is to prevent accidental deletion of the webauth workspace."
}

resource "azurerm_private_dns_zone" "webauth" {
  name                = "privatelink.azuredatabricks.net"
  resource_group_name = azurerm_resource_group.webauth.name
}

resource "azurerm_private_endpoint" "webauth" {
  name                = "webauth-private-endpoint"
  location            = azurerm_resource_group.webauth.location
  resource_group_name = azurerm_resource_group.webauth.name
  subnet_id           = azurerm_subnet.privatelink.id

  private_service_connection {
    name                           = "pl-webauth"
    private_connection_resource_id = azurerm_databricks_workspace.webauth.id
    is_manual_connection           = false
    subresource_names              = ["browser_authentication"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-webauth"
    private_dns_zone_ids = [azurerm_private_dns_zone.webauth.id]
  }
}
