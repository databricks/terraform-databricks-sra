# Define a private endpoint resource for webauth (browser authentication)
resource "azurerm_private_endpoint" "webauth" {
  count = var.create_webauth_private_endpoint ? 1 : 0

  name                = "${lookup(var.name_overrides, "private_endpoint", module.naming.private_endpoint.name_unique)}-webauth"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = data.azurerm_subnet.private_endpoint.id

  # Configure the private service connection
  private_service_connection {
    name                           = "ple-${var.resource_suffix}-webauth"
    private_connection_resource_id = azurerm_databricks_workspace.this.id
    is_manual_connection           = false
    subresource_names              = ["browser_authentication"]
  }

  # Configure the private DNS zone group
  private_dns_zone_group {
    name                 = "private-dns-zone-webauth"
    private_dns_zone_ids = [var.dns_zone_ids.backend]
  }

  depends_on = [azurerm_private_endpoint.backend]
  tags       = var.tags
}

