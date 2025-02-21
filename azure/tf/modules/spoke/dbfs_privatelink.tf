# Define a private DNS zone for the dbfs_dfs resource
resource "azurerm_private_dns_zone" "dbfs_dfs" {
  count = var.boolean_create_private_dbfs ? 1 : 0

  name                = "privatelink.dfs.core.windows.net"
  resource_group_name = azurerm_resource_group.this.name

  tags       = var.tags
  depends_on = [azurerm_databricks_workspace.this]
}

# Define a private endpoint for the dbfs_dfs resource
resource "azurerm_private_endpoint" "dbfs_dfs" {
  count = var.boolean_create_private_dbfs ? 1 : 0

  name                = "dbfspe-dfs"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.privatelink.id

  # Define the private service connection for the dbfs_dfs resource
  private_service_connection {
    name                           = "ple-${var.resource_suffix}-dbfs-dfs"
    private_connection_resource_id = join("", [azurerm_databricks_workspace.this.managed_resource_group_id, "/providers/Microsoft.Storage/storageAccounts/", local.dbfs_name])
    is_manual_connection           = false
    subresource_names              = ["dfs"]
  }

  # Associate the private DNS zone with the private endpoint
  private_dns_zone_group {
    name                 = "private-dns-zone-dbfs"
    private_dns_zone_ids = [azurerm_private_dns_zone.dbfs_dfs[0].id]
  }

  tags       = var.tags
  depends_on = [azurerm_databricks_workspace.this]
}

# Define a virtual network link for the dbfs_dfs private DNS zone
resource "azurerm_private_dns_zone_virtual_network_link" "dbfs_dfs" {
  count = var.boolean_create_private_dbfs ? 1 : 0

  name                  = "dbfs-dfs"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.dbfs_dfs[0].name
  virtual_network_id    = azurerm_virtual_network.this.id

  tags       = var.tags
  depends_on = [azurerm_databricks_workspace.this]
}

# Define a private endpoint for the dbfs_blob resource
resource "azurerm_private_endpoint" "dbfspe_blob" {
  count = var.boolean_create_private_dbfs ? 1 : 0

  name                = "dbfs-blob"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.privatelink.id

  # Define the private service connection for the dbfs_blob resource
  private_service_connection {
    name                           = "ple-${var.resource_suffix}-dbfs-blob"
    private_connection_resource_id = join("", [azurerm_databricks_workspace.this.managed_resource_group_id, "/providers/Microsoft.Storage/storageAccounts/", local.dbfs_name])
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  # Associate the private DNS zone with the private endpoint
  private_dns_zone_group {
    name                 = "private-dns-zone-dbfs"
    private_dns_zone_ids = [azurerm_private_dns_zone.dbfs_blob[0].id]
  }

  tags       = var.tags
  depends_on = [azurerm_databricks_workspace.this]
}

# Define a private DNS zone for the dbfs_blob resource
resource "azurerm_private_dns_zone" "dbfs_blob" {
  count = var.boolean_create_private_dbfs ? 1 : 0

  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.this.name

  tags       = var.tags
  depends_on = [azurerm_databricks_workspace.this]
}

# Define a virtual network link for the dbfs_blob private DNS zone
resource "azurerm_private_dns_zone_virtual_network_link" "dbfs_blob" {
  count = var.boolean_create_private_dbfs ? 1 : 0

  name                  = "dbfs-blob"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.dbfs_blob[0].name
  virtual_network_id    = azurerm_virtual_network.this.id

  tags       = var.tags
  depends_on = [azurerm_databricks_workspace.this]
}

<<<<<<< HEAD
=======
# NCC access to DBFS

data "azurerm_storage_account" "dbfs" {
  depends_on          = [azurerm_databricks_workspace.this]
  name                = local.dbfs_name
  resource_group_name = local.managed_rg_name

}
resource "databricks_mws_ncc_private_endpoint_rule" "dbfs_blob" {
  network_connectivity_config_id = var.ncc_id
  resource_id                    = data.azurerm_storage_account.dbfs.id
  group_id                       = "blob"
}

resource "databricks_mws_ncc_private_endpoint_rule" "dbfs_dfs" {
  network_connectivity_config_id = var.ncc_id
  resource_id                    = data.azurerm_storage_account.dbfs.id
  group_id                       = "dfs"
}
>>>>>>> 8d44021 (serverless and classic compute working)
