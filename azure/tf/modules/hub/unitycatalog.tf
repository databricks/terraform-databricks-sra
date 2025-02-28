locals {
  # If the user provides a storage account name, use it. If they do not, check if the resource_suffix was left defaulted. If it was, generate a unique storage account name, else use a non-unique storage account name (assuming the resource suffix is unique).
  storage_account_name = coalesce(var.storage_account_name, var.resource_suffix == "hub" ? "${module.naming.storage_account.name_unique}uc" : "${module.naming.storage_account.name}uc")
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

# Define a Databricks Metastore resource
resource "databricks_metastore" "this" {
  count = var.is_unity_catalog_enabled ? 1 : 0

  name = "uc-metastore-${var.resource_suffix}"
  storage_root = format("abfss://%s@%s.dfs.core.windows.net/",
    azurerm_storage_container.unity_catalog[0].name,
  azurerm_storage_account.unity_catalog[0].name)
  # owner         = "uc admins"
  region        = azurerm_resource_group.this.location
  force_destroy = true
}

# Define a Databricks Metastore Data Access resource
# TODO - figure out how to test internally with MI
resource "databricks_metastore_data_access" "this" {
  count = var.is_unity_catalog_enabled ? 1 : 0

  metastore_id = databricks_metastore.this[0].id
  name         = "dac-${var.resource_suffix}"
  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.unity_catalog[0].id
  }

  force_destroy = true

  is_default = true

  lifecycle {
    ignore_changes = [azure_service_principal]
  }
}

resource "databricks_group" "this" {
  count = var.is_unity_catalog_enabled ? 1 : 0

  display_name = "${var.resource_suffix}-uc-owners"
}
