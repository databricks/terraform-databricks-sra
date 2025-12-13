# Define a private DNS zone resource for the backend
resource "azurerm_private_dns_zone" "backend" {
  name                = "privatelink.azuredatabricks.net"
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Define a virtual network link for the private DNS zone and the backend virtual network
resource "azurerm_private_dns_zone_virtual_network_link" "backend" {
  name                  = "databricks-vnetlink-backend"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.backend.name
  virtual_network_id    = azurerm_virtual_network.this.id

  tags = var.tags
}

# Define a private DNS zone for the dbfs_dfs resource
resource "azurerm_private_dns_zone" "dbfs_dfs" {
  name                = "privatelink.dfs.core.windows.net"
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Define a virtual network link for the dbfs_dfs private DNS zone
resource "azurerm_private_dns_zone_virtual_network_link" "dbfs_dfs" {
  name                  = "dbfs-dfs"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.dbfs_dfs.name
  virtual_network_id    = azurerm_virtual_network.this.id

  tags = var.tags
}

# Define a private DNS zone for the dbfs_blob resource
resource "azurerm_private_dns_zone" "dbfs_blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Define a virtual network link for the dbfs_blob private DNS zone
resource "azurerm_private_dns_zone_virtual_network_link" "dbfs_blob" {
  name                  = "dbfs-blob"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.dbfs_blob.name
  virtual_network_id    = azurerm_virtual_network.this.id

  tags = var.tags
}
