# Private DNS zone for Databricks backend/webauth
resource "azurerm_private_dns_zone" "backend" {
  name                = "privatelink.azuredatabricks.net"
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "backend" {
  name                  = "databricks-vnetlink-backend"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.backend.name
  virtual_network_id    = azurerm_virtual_network.this.id
  tags                  = var.tags
}

# Conditional DBFS DNS zones
resource "azurerm_private_dns_zone" "dbfs_dfs" {
  count               = var.boolean_create_private_dbfs ? 1 : 0
  name                = "privatelink.dfs.core.windows.net"
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "dbfs_dfs" {
  count                 = var.boolean_create_private_dbfs ? 1 : 0
  name                  = "dbfs-dfs"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.dbfs_dfs[0].name
  virtual_network_id    = azurerm_virtual_network.this.id
  tags                  = var.tags
}

resource "azurerm_private_dns_zone" "dbfs_blob" {
  count               = var.boolean_create_private_dbfs ? 1 : 0
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "dbfs_blob" {
  count                 = var.boolean_create_private_dbfs ? 1 : 0
  name                  = "dbfs-blob"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.dbfs_blob[0].name
  virtual_network_id    = azurerm_virtual_network.this.id
  tags                  = var.tags
}

