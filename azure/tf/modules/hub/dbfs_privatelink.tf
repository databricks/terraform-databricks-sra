locals {
  dbfs_sa_resource_id = join("", [azurerm_databricks_workspace.webauth.managed_resource_group_id, "/providers/Microsoft.Storage/storageAccounts/", local.dbfs_name])
}

# Define a private DNS zone for the dbfs_dfs resource
resource "azurerm_private_dns_zone" "dbfs_dfs" {
  count = var.boolean_create_private_dbfs ? 1 : 0

  name                = "privatelink.dfs.core.windows.net"
  resource_group_name = azurerm_resource_group.this.name

  tags       = var.tags
  depends_on = [azurerm_databricks_workspace.webauth]
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
    private_connection_resource_id = local.dbfs_sa_resource_id
    is_manual_connection           = false
    subresource_names              = ["dfs"]
  }

  # Associate the private DNS zone with the private endpoint
  private_dns_zone_group {
    name                 = "private-dns-zone-dbfs"
    private_dns_zone_ids = [azurerm_private_dns_zone.dbfs_dfs[0].id]
  }

  tags       = var.tags
  depends_on = [azurerm_databricks_workspace.webauth]
}

# Define a virtual network link for the dbfs_dfs private DNS zone
resource "azurerm_private_dns_zone_virtual_network_link" "dbfs_dfs" {
  count = var.boolean_create_private_dbfs ? 1 : 0

  name                  = "dbfs-dfs"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.dbfs_dfs[0].name
  virtual_network_id    = azurerm_virtual_network.this.id

  tags       = var.tags
  depends_on = [azurerm_databricks_workspace.webauth]
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
    private_connection_resource_id = local.dbfs_sa_resource_id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  # Associate the private DNS zone with the private endpoint
  private_dns_zone_group {
    name                 = "private-dns-zone-dbfs"
    private_dns_zone_ids = [azurerm_private_dns_zone.dbfs_blob[0].id]
  }

  tags       = var.tags
  depends_on = [azurerm_databricks_workspace.webauth]
}

# Define a private DNS zone for the dbfs_blob resource
resource "azurerm_private_dns_zone" "dbfs_blob" {
  count = var.boolean_create_private_dbfs ? 1 : 0

  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.this.name

  tags       = var.tags
  depends_on = [azurerm_databricks_workspace.webauth]
}

# Define a virtual network link for the dbfs_blob private DNS zone
resource "azurerm_private_dns_zone_virtual_network_link" "dbfs_blob" {
  count = var.boolean_create_private_dbfs ? 1 : 0

  name                  = "dbfs-blob"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.dbfs_blob[0].name
  virtual_network_id    = azurerm_virtual_network.this.id

  tags       = var.tags
  depends_on = [azurerm_databricks_workspace.webauth]
}

module "ncc_dbfs_blob" {
  source = "../self-approving-pe"
  count  = var.boolean_create_private_dbfs ? 1 : 0

  group_id                         = "blob"
  network_connectivity_config_id   = databricks_mws_network_connectivity_config.this.network_connectivity_config_id
  resource_id                      = local.dbfs_sa_resource_id
  network_connectivity_config_name = databricks_mws_network_connectivity_config.this.name
}

module "ncc_dbfs_dfs" {
  source = "../self-approving-pe"
  count  = var.boolean_create_private_dbfs ? 1 : 0

  group_id                         = "dfs"
  network_connectivity_config_id   = databricks_mws_network_connectivity_config.this.network_connectivity_config_id
  resource_id                      = local.dbfs_sa_resource_id
  network_connectivity_config_name = databricks_mws_network_connectivity_config.this.name
}

# Access connector for the workspace to use for accessing workspace/dbfs storage
resource "azurerm_databricks_access_connector" "ws" {
  count = var.boolean_create_private_dbfs ? 1 : 0

  # "ws" is used in the name to indicate that this access connector is for workspace storage
  name                = "id-databricks-ws-${var.resource_suffix}"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  identity {
    type = "SystemAssigned"
  }
  tags = var.tags
}
