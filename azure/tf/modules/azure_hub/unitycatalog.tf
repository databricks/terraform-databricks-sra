# Define an Azure Databricks access connector resource
resource "azurerm_databricks_access_connector" "unity_catalog" {
  name                = "${local.prefix}-databricks-mi"
  resource_group_name = azurerm_resource_group.hub.name
  location            = azurerm_resource_group.hub.location
  identity {
    type = "SystemAssigned"
  }
}

# Define an Azure Storage Account resource
resource "azurerm_storage_account" "unity_catalog" {
  name                          = "${local.prefix}unity"
  resource_group_name           = azurerm_resource_group.hub.name
  location                      = azurerm_resource_group.hub.location
  tags                          = azurerm_resource_group.hub.tags
  account_tier                  = "Standard"
  account_replication_type      = "GRS"
  is_hns_enabled                = true
  public_network_access_enabled = false
}

# Define an Azure Storage Container resource
resource "azurerm_storage_container" "unity_catalog" {
  name                  = "${local.prefix}-container"
  storage_account_name  = azurerm_storage_account.unity_catalog.name
  container_access_type = "private"
}

# Define an Azure role assignment resource
resource "azurerm_role_assignment" "this" {
  scope                = azurerm_storage_account.unity_catalog.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_databricks_access_connector.unity_catalog.identity[0].principal_id
}

# Define a Databricks Metastore resource
resource "databricks_metastore" "this" {
  name = "primary"
  storage_root = format("abfss://%s@%s.dfs.core.windows.net/",
    azurerm_storage_container.unity_catalog.name,
  azurerm_storage_account.unity_catalog.name)
  owner         = "uc admins"
  region        = azurerm_resource_group.hub.location
  force_destroy = true
}

# Define a Databricks Metastore Data Access resource
resource "databricks_metastore_data_access" "this" {
  metastore_id = databricks_metastore.this.id
  name         = "mi_dac"
  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.unity_catalog.id
  }

  is_default = true
}
