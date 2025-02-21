resource "databricks_mws_network_connectivity_config" "this" {
  name   = "ncc-for-${var.resource_suffix}"
  region = azurerm_resource_group.this.location
}

resource "databricks_mws_ncc_private_endpoint_rule" "storage" {
  network_connectivity_config_id = databricks_mws_network_connectivity_config.this.network_connectivity_config_id
  resource_id                    = azurerm_storage_account.unity_catalog[0].id
  group_id                       = "dfs"
}
