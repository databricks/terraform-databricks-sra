resource "azurerm_databricks_access_connector" "unity_catalog" {
  name                = "${local.prefix}-databricks-mi"
  resource_group_name = azurerm_resource_group.hub.name
  location            = azurerm_resource_group.hub.location
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_storage_account" "unity_catalog" {
  name                     = "${local.prefix}unity"
  resource_group_name      = azurerm_resource_group.hub.name
  location                 = azurerm_resource_group.hub.location
  tags                     = azurerm_resource_group.hub.tags
  account_tier             = "Standard"
  account_replication_type = "GRS"
  is_hns_enabled           = true
}

resource "azurerm_storage_container" "unity_catalog" {
  name                  = "${local.prefix}-container"
  storage_account_name  = azurerm_storage_account.unity_catalog.name
  container_access_type = "private"
}

resource "azurerm_role_assignment" "this" {
  scope                = azurerm_storage_account.unity_catalog.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_databricks_access_connector.unity_catalog.identity[0].principal_id
}

resource "databricks_metastore" "this" {
  name = "primary"
  storage_root = format("abfss://%s@%s.dfs.core.windows.net/",
    azurerm_storage_container.unity_catalog.name,
  azurerm_storage_account.unity_catalog.name)
  owner         = "uc admins"
  region        = azurerm.resource_group.this.location
  force_destroy = true
}

resource "databricks_metastore_data_access" "this" {
  metastore_id = databricks_metastore.this.id
  name         = "mi_dac"
  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.unity.id
  }

  is_default = true
}