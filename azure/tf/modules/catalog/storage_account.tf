# Define an Azure Databricks access connector resource
resource "azurerm_databricks_access_connector" "unity_catalog" {
  name                = "id-databricks-${var.resource_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  identity {
    type = "SystemAssigned"
  }
  tags = var.tags
}

# Define an Azure Storage Account resource
resource "azurerm_storage_account" "unity_catalog" {
  name                            = local.storage_account_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = var.storage_account_replication_type
  is_hns_enabled                  = true
  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false

  network_rules {
    default_action = "Deny"
    bypass         = ["None"]
    private_link_access {
      endpoint_resource_id = azurerm_databricks_access_connector.unity_catalog.id
    }
  }

  tags = var.tags
}

# Define an Azure Storage Container resource
resource "azurerm_storage_container" "unity_catalog" {
  name                  = var.storage_container_name
  storage_account_id    = azurerm_storage_account.unity_catalog.id
  container_access_type = "private"
}

# Define an Azure role assignment resource
resource "azurerm_role_assignment" "blob_data_contrib" {
  scope                = azurerm_storage_account.unity_catalog.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = local.access_connector_mi_id
}

resource "azurerm_role_assignment" "queue_contrib" {
  scope                = azurerm_storage_account.unity_catalog.id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = local.access_connector_mi_id
}

resource "azurerm_role_assignment" "event_contrib" {
  scope                = azurerm_storage_account.unity_catalog.id
  role_definition_name = "EventGrid EventSubscription Contributor"
  principal_id         = local.access_connector_mi_id
}
