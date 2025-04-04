resource "databricks_mws_network_connectivity_config" "this" {
  name   = "ncc-for-${var.resource_suffix}"
  region = azurerm_resource_group.this.location
}

# NCC access to DBFS
data "azurerm_storage_account" "dbfs" {
  name                = local.dbfs_name
  resource_group_name = azurerm_databricks_workspace.webauth.managed_resource_group_name
}

resource "databricks_mws_ncc_private_endpoint_rule" "dbfs_blob" {
  network_connectivity_config_id = databricks_mws_network_connectivity_config.this.network_connectivity_config_id
  resource_id                    = data.azurerm_storage_account.dbfs.id
  group_id                       = "blob"
}

resource "databricks_mws_ncc_private_endpoint_rule" "dbfs_dfs" {
  network_connectivity_config_id = databricks_mws_network_connectivity_config.this.network_connectivity_config_id
  resource_id                    = data.azurerm_storage_account.dbfs.id
  group_id                       = "dfs"
}
