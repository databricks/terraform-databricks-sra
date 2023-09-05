resource "azurerm_private_endpoint" "backend" {
  name                = "databricks-pe-backend"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.privatelink.id

  private_service_connection {
    name                           = "ple-${var.prefix}-backend"
    private_connection_resource_id = azurerm_databricks_workspace.this.id
    is_manual_connection           = false
    subresource_names              = ["databricks_ui_api"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-backend"
    private_dns_zone_ids = [azurerm_private_dns_zone.backend.id]
  }
}

resource "azurerm_private_dns_zone" "backend" {
  name                = "privatelink.azuredatabricks.net"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "backend" {
  name                  = "databricks-vnetlink-backend"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.backend.name
  virtual_network_id    = azurerm_virtual_network.this.id
}
