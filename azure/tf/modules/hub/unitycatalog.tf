<<<<<<< HEAD
=======
# Define an Azure Databricks access connector resource
resource "azurerm_databricks_access_connector" "unity_catalog" {
  count = var.is_unity_catalog_enabled ? 1 : 0

  name                = "${local.prefix}-databricks-mi"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  identity {
    type = "SystemAssigned"
  }
}

# Define an Azure Storage Account resource
resource "azurerm_storage_account" "unity_catalog" {
  count = var.is_unity_catalog_enabled ? 1 : 0

  name                     = "${local.prefix}unity"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  is_hns_enabled           = true

  lifecycle {
    ignore_changes = [tags]
  }
}

# Define an Azure Storage Container resource
resource "azurerm_storage_container" "unity_catalog" {
  count = var.is_unity_catalog_enabled ? 1 : 0

  name                  = "${local.prefix}-container"
  storage_account_id    = azurerm_storage_account.unity_catalog[0].name
  container_access_type = "private"
}

# Define an Azure role assignment resource
resource "azurerm_role_assignment" "this" {
  count = var.is_unity_catalog_enabled ? 1 : 0

  scope                = azurerm_storage_account.unity_catalog[0].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_databricks_access_connector.unity_catalog[0].identity[0].principal_id
}

>>>>>>> 60cc2bc (remove redundant module naming)
# Define a Databricks Metastore resource
resource "databricks_metastore" "this" {
  count = var.is_unity_catalog_enabled ? 1 : 0

<<<<<<< HEAD
  name = "uc-metastore-${var.resource_suffix}"
=======
  name = "${local.prefix}-metastore"
  storage_root = format("abfss://%s@%s.dfs.core.windows.net/",
    azurerm_storage_container.unity_catalog[0].name,
  azurerm_storage_account.unity_catalog[0].name)
>>>>>>> 60cc2bc (remove redundant module naming)
  # owner         = "uc admins"
  region        = azurerm_resource_group.this.location
  force_destroy = true
}

<<<<<<< HEAD
resource "databricks_group" "this" {
  count = var.is_unity_catalog_enabled ? 1 : 0

  display_name = "${var.resource_suffix}-uc-owners"
=======
# Define a Databricks Metastore Data Access resource
# TODO - figure out how to test internally with MI
resource "databricks_metastore_data_access" "this" {
  count = var.is_unity_catalog_enabled ? 1 : 0

  metastore_id = databricks_metastore.this[0].id
  name         = "${local.prefix}-dac"
  azure_service_principal {
    directory_id   = local.tenant_id
    application_id = var.application_id
    client_secret  = var.client_secret
  }

  is_default = true

  lifecycle {
    ignore_changes = [azure_service_principal]
  }
}

resource "databricks_group" "this" {
  count = var.is_unity_catalog_enabled ? 1 : 0

  display_name = "${local.prefix}-uc-owners"
>>>>>>> 60cc2bc (remove redundant module naming)
}
