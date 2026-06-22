resource "azurerm_private_endpoint" "webauth" {
  name                = "${lookup(var.name_overrides, "private_endpoint", module.naming.private_endpoint.name_unique)}-webauth"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "ple-${var.resource_suffix}-webauth"
    private_connection_resource_id = azapi_resource.this.id
    is_manual_connection           = false
    subresource_names              = ["browser_authentication"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-webauth"
    private_dns_zone_ids = [var.dns_zone_ids.backend]
  }

  tags = var.tags
}
