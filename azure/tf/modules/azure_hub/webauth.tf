resource "azurerm_resource_group" "webauth" {
  name     = "webauthrg"
  location = var.location
}
resource "azurerm_virtual_network" "webauth" {
  name                = "webauthvnet"
  location            = azurerm_resource_group.webauth.location
  resource_group_name = azurerm_resource_group.webauth.name
  address_space       = [var.webauth_cidr] # /24
}

resource "azurerm_subnet" "private" {
  name                 = "webauth-private"
  resource_group_name  = azurerm_resource_group.webauth.name
  virtual_network_name = azurerm_virtual_network.webauth.name

  address_prefixes = [cidrsubnet(var.webauth_cidr, 2, 0)] # /26

  delegation {
    name = "databricks-private-subnet-delegation"

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

resource "azurerm_subnet" "public" {
  name                 = "webauth-public"
  resource_group_name  = azurerm_resource_group.webauth.name
  virtual_network_name = azurerm_virtual_network.webauth.name

  address_prefixes = [cidrsubnet(var.webauth_cidr, 2, 1)] # /26

  delegation {
    name = "databricks-public-subnet-delegation"

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
  name                 = "webauth-privatelink"
  resource_group_name  = azurerm_resource_group.webauth.name
  virtual_network_name = azurerm_virtual_network.webauth.name

  address_prefixes = [cidrsubnet(var.webauth_cidr, 2, 2)] # /26
}

resource "azurerm_network_security_group" "webauth" {
  name                = "webauth-nsg"
  location            = azurerm_resource_group.webauth.location
  resource_group_name = azurerm_resource_group.webauth.name
}

resource "azurerm_subnet_network_security_group_association" "private" {
  subnet_id                 = azurerm_subnet.private.id
  network_security_group_id = azurerm_network_security_group.webauth.id
}

resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id                 = azurerm_subnet.public.id
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
    virtual_network_id                                   = azurerm_virtual_network.webauth.id
    private_subnet_name                                  = azurerm_subnet.private.name
    public_subnet_name                                   = azurerm_subnet.public.name
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.private.id
    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.public.id
  }

  tags = var.tags
}

resource "azurerm_management_lock" "webauth" {
  name       = "webauth-do-not-delete"
  scope      = azurerm_databricks_workspace.webauth.id
  lock_level = "CanNotDelete"
  notes = "This lock is to prevent accidental deletion of the webauth workspace."
}

resource "azurerm_private_dns_zone" "webauth" {
  name                = "privatelink.azuredatabricks.net"
  resource_group_name = azurerm_resource_group.webauth.name
}

resource "azurerm_private_endpoint" "webauth" {
  name                = "webauth-private-endpoint"
  location            = azurerm_resource_group.webauth.location
  resource_group_name = azurerm_resource_group.webauth.name
  subnet_id           = azurerm_subnet.privatelink.id //private link subnet, in databricks spoke vnet

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
