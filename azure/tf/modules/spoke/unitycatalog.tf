locals {
  # If the user provides a storage account name, use it. If they do not, check if the resource_suffix was left defaulted. If it was, generate a unique storage account name, else use a non-unique storage account name (assuming the resource suffix is unique).
  storage_account_name = coalesce(var.storage_account_name, "${module.naming.storage_account.name}uc")
}

# Define an Azure Databricks access connector resource
resource "azurerm_databricks_access_connector" "unity_catalog" {
  count = var.is_unity_catalog_enabled ? 1 : 0

  name                = "databricks-mi-${var.resource_suffix}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# Define an Azure Storage Account resource
resource "azurerm_storage_account" "unity_catalog" {
  count = var.is_unity_catalog_enabled ? 1 : 0

  name                          = local.storage_account_name
  resource_group_name           = azurerm_resource_group.this.name
  location                      = azurerm_resource_group.this.location
  account_tier                  = "Standard"
  account_replication_type      = "GRS"
  is_hns_enabled                = true
  public_network_access_enabled = false
  network_rules {
    default_action = "Deny"
    bypass         = ["None"]
    private_link_access {
      endpoint_resource_id = azurerm_databricks_access_connector.unity_catalog[0].id
    }
  }

  tags = var.tags
}

# Define an Azure Storage Container resource
resource "azurerm_storage_container" "unity_catalog" {
  count = var.is_unity_catalog_enabled ? 1 : 0

  name                  = "default"
  storage_account_id    = azurerm_storage_account.unity_catalog[0].id
  container_access_type = "private"
}

# Define an Azure role assignment resource
resource "azurerm_role_assignment" "this" {
  count = var.is_unity_catalog_enabled ? 1 : 0

  scope                = azurerm_storage_account.unity_catalog[0].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_databricks_access_connector.unity_catalog[0].identity[0].principal_id
}

resource "azurerm_private_endpoint" "uc_dfs" {
  count = var.is_unity_catalog_enabled ? 1 : 0

  name                = "ucpe-dfs"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.privatelink.id

  # Define the private service connection for the dbfs_dfs resource
  private_service_connection {
    name                           = "ple-${var.resource_suffix}-uc-dfs"
    private_connection_resource_id = azurerm_storage_account.unity_catalog[0].id
    is_manual_connection           = false
    subresource_names              = ["dfs"]
  }

  # Associate the private DNS zone with the private endpoint
  private_dns_zone_group {
    name                 = "private-dns-zone-uc"
    private_dns_zone_ids = [azurerm_private_dns_zone.dbfs_dfs[0].id]
  }

  tags = var.tags
}

resource "databricks_storage_credential" "unity_catalog" {
  count = var.is_unity_catalog_enabled ? 1 : 0

  name         = "cred-${var.resource_suffix}"
  metastore_id = var.metastore_id
  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.unity_catalog[0].id
  }
}
