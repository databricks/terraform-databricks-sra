# NCC access to DBFS
data "azurerm_storage_account" "dbfs" {
  depends_on          = [azurerm_databricks_workspace.this]
  name                = local.dbfs_name
  resource_group_name = local.managed_rg_name
}

module "ncc_dbfs_blob" {
  source = "../self-approving-pe"

  group_id                         = "blob"
  network_connectivity_config_id   = var.ncc_id
  resource_id                      = data.azurerm_storage_account.dbfs.id
  network_connectivity_config_name = var.ncc_name
}

module "ncc_dbfs_dfs" {
  source = "../self-approving-pe"

  group_id                         = "dfs"
  network_connectivity_config_id   = var.ncc_id
  resource_id                      = data.azurerm_storage_account.dbfs.id
  network_connectivity_config_name = var.ncc_name
}
