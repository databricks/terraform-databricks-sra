# This resource block defines a subnet for the host
resource "azurerm_subnet" "host" {
  name                 = "webauth-host"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name

  address_prefixes = [var.subnet_map["webauth-host"]]

  # This delegation block specifies the actions that can be performed on the subnet by the Microsoft.Databricks/workspaces service
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

# This resource block defines a subnet for the container
resource "azurerm_subnet" "container" {
  name                 = "webauth-container"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name

  address_prefixes = [var.subnet_map["webauth-container"]]

  # This delegation block specifies the actions that can be performed on the subnet by the Microsoft.Databricks/workspaces service
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

# This resource block defines a network security group for webauth
resource "azurerm_network_security_group" "webauth" {
  name                = "webauth-nsg"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  tags = var.tags
}

# This resource block associates the container subnet with the webauth network security group
resource "azurerm_subnet_network_security_group_association" "container" {
  subnet_id                 = azurerm_subnet.container.id
  network_security_group_id = azurerm_network_security_group.webauth.id
}

# This resource block associates the host subnet with the webauth network security group
resource "azurerm_subnet_network_security_group_association" "host" {
  subnet_id                 = azurerm_subnet.host.id
  network_security_group_id = azurerm_network_security_group.webauth.id
}

# This resource block defines a databricks workspace for webauth
resource "azurerm_databricks_workspace" "webauth" {
  name                        = join("_", ["WEB_AUTH_DO_NOT_DELETE", upper(azurerm_resource_group.this.location)])
  resource_group_name         = azurerm_resource_group.this.name
  managed_resource_group_name = local.managed_rg_name
  location                    = azurerm_resource_group.this.location
  sku                         = "premium"

  # managed_disk_cmk_rotation_to_latest_version_enabled = var.is_kms_enabled ? true : false
  managed_disk_cmk_key_vault_key_id     = var.is_kms_enabled ? azurerm_key_vault_key.managed_disk[0].id : null
  managed_services_cmk_key_vault_key_id = var.is_kms_enabled ? azurerm_key_vault_key.managed_services[0].id : null
  customer_managed_key_enabled          = var.is_kms_enabled
  infrastructure_encryption_enabled     = var.is_kms_enabled
  public_network_access_enabled         = !var.is_frontend_private_link_enabled
  network_security_group_rules_required = var.is_frontend_private_link_enabled ? "NoAzureDatabricksRules" : "AllRules"

  # This custom_parameters block specifies additional parameters for the databricks workspace
  custom_parameters {
    storage_account_name                                 = local.dbfs_name
    no_public_ip                                         = true
    virtual_network_id                                   = azurerm_virtual_network.this.id
    private_subnet_name                                  = azurerm_subnet.container.name
    public_subnet_name                                   = azurerm_subnet.host.name
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.container.id
    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.host.id
  }

  tags = var.tags
}

# Define an Azure Key Vault access policy for Databricks
resource "azurerm_key_vault_access_policy" "dbstorage" {
  count = var.is_kms_enabled ? 1 : 0

  key_vault_id = azurerm_key_vault.this[0].id
  tenant_id    = azurerm_databricks_workspace.webauth.storage_account_identity[0].tenant_id
  object_id    = azurerm_databricks_workspace.webauth.storage_account_identity[0].principal_id

  key_permissions = [
    "Get",
    "UnwrapKey",
    "WrapKey",
  ]
}

resource "azurerm_key_vault_access_policy" "dbmanageddisk" {
  count = var.is_kms_enabled ? 1 : 0

  key_vault_id = azurerm_key_vault.this[0].id
  tenant_id    = azurerm_databricks_workspace.webauth.managed_disk_identity[0].tenant_id
  object_id    = azurerm_databricks_workspace.webauth.managed_disk_identity[0].principal_id

  key_permissions = [
    "Get",
    "UnwrapKey",
    "WrapKey",
  ]
}

resource "azurerm_databricks_workspace_root_dbfs_customer_managed_key" "this" {
  count = var.is_kms_enabled ? 1 : 0

  workspace_id     = azurerm_databricks_workspace.webauth.id
  key_vault_key_id = azurerm_key_vault_key.managed_disk[0].id

  depends_on = [azurerm_key_vault_access_policy.databricks]
}

# This resource block defines a private DNS zone Databricks
resource "azurerm_private_dns_zone" "auth_front" {
  name                = "privatelink.azuredatabricks.net"
  resource_group_name = azurerm_resource_group.this.name

  tags = var.tags
}

# This resource block defines a private endpoint for webauth
resource "azurerm_private_endpoint" "webauth" {
  name                = "webauth-private-endpoint"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.privatelink.id

  tags = var.tags

  depends_on = [azurerm_subnet.privatelink] # for proper destruction order

  # This private_service_connection block specifies the connection details for the private endpoint
  private_service_connection {
    name                           = "pl-webauth"
    private_connection_resource_id = azurerm_databricks_workspace.webauth.id
    is_manual_connection           = false
    subresource_names              = ["browser_authentication"]
  }

  # This private_dns_zone_group block specifies the private DNS zone to associate with the private endpoint
  private_dns_zone_group {
    name                 = "private-dns-zone-webauth"
    private_dns_zone_ids = [azurerm_private_dns_zone.auth_front.id]
  }
}

resource "databricks_metastore_assignment" "webauth" {
  count = var.is_unity_catalog_enabled ? 1 : 0

  workspace_id = azurerm_databricks_workspace.webauth.workspace_id
  metastore_id = databricks_metastore.this[0].id
}

resource "databricks_mws_ncc_binding" "this" {
  network_connectivity_config_id = databricks_mws_network_connectivity_config.this.network_connectivity_config_id
  workspace_id                   = azurerm_databricks_workspace.webauth.workspace_id
}
