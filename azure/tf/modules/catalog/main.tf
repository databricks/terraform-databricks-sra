locals {
  # If the user provides a storage account name, use it. If they do not, check if the resource_suffix was left defaulted. If it was, generate a unique storage account name, else use a non-unique storage account name (assuming the resource suffix is unique).
  storage_account_name   = coalesce(var.storage_account_name, "${module.naming.storage_account.name}uc")
  uc_abfss_url           = "abfss://${azurerm_storage_container.unity_catalog.name}@${azurerm_storage_account.unity_catalog.primary_dfs_host}/"
  access_connector_mi_id = azurerm_databricks_access_connector.unity_catalog.identity[0].principal_id
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~>0.4"
  suffix  = [var.resource_suffix]
}

resource "databricks_storage_credential" "unity_catalog" {
  name         = "cred-${var.resource_suffix}"
  metastore_id = var.metastore_id
  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.unity_catalog.id
  }

  provider = databricks.workspace
}

resource "databricks_external_location" "external_location" {
  credential_name = databricks_storage_credential.unity_catalog.name
  name            = azurerm_storage_account.unity_catalog.name
  url             = local.uc_abfss_url

  provider = databricks.workspace
}

resource "databricks_catalog" "catalog" {
  name           = var.catalog_name
  storage_root   = databricks_external_location.external_location.url
  force_destroy  = var.force_destroy
  isolation_mode = var.catalog_isolation_mode

  provider = databricks.workspace
}
