# Define an Azure Databricks access connector resource
resource "azurerm_databricks_access_connector" "unity_catalog" {
  name                = "${local.prefix}-databricks-mi"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  identity {
    type = "SystemAssigned"
  }
}

# Define an Azure Storage Account resource
resource "azurerm_storage_account" "unity_catalog" {
  name                = "${local.prefix}unity"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  # tags                     = azurerm_resource_group.this.tags
  account_tier             = "Standard"
  account_replication_type = "GRS"
  is_hns_enabled           = true
  # public_network_access_enabled = true # should be false, but terraform 403s when false

  #   network_rules {
  #     default_action = "Deny"
  #     bypass         = ["None"]
  #     private_link_access {
  #       endpoint_resource_id = azurerm_databricks_access_connector.unity_catalog.id
  #     }
  #   }

  lifecycle {
    ignore_changes = [tags]
  }
}

# Define an Azure Storage Container resource
resource "azurerm_storage_container" "unity_catalog" {
  name                  = "${local.prefix}-container"
  # storage_account_name  = azurerm_storage_account.unity_catalog.name # deprecated in future versions in favour of storage_account_id
  storage_account_id  = azurerm_storage_account.unity_catalog.id
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
  name = "${local.prefix}-metastore"
  storage_root = format("abfss://%s@%s.dfs.core.windows.net/",
    azurerm_storage_container.unity_catalog.name,
  azurerm_storage_account.unity_catalog.name)
  # owner         = "uc admins"
  region        = azurerm_resource_group.this.location
  force_destroy = true
}

# Define a Databricks Metastore Data Access resource
# TODO - figure out how to test internally with MI
resource "databricks_metastore_data_access" "this" {
  metastore_id = databricks_metastore.this.id
  name         = "${local.prefix}-dac"
  # azure_managed_identity {
  #   access_connector_id = azurerm_databricks_access_connector.unity_catalog.id
  # }
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
  display_name = "${local.prefix}-uc-owners"
}
