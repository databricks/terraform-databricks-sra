# Define a private endpoint resource for the backend
resource "azurerm_private_endpoint" "backend" {
  count = var.create_backend_private_endpoint ? 1 : 0

  name                = "${lookup(var.name_overrides, "private_endpoint", module.naming.private_endpoint.name_unique)}-backend"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = data.azurerm_subnet.private_endpoint.id

  # Configure the private service connection
  private_service_connection {
    name                           = "ple-${var.resource_suffix}-backend"
    private_connection_resource_id = azurerm_databricks_workspace.this.id
    is_manual_connection           = false
    subresource_names              = ["databricks_ui_api"]
  }

  # Configure the private DNS zone group
  private_dns_zone_group {
    name                 = "private-dns-zone-backend"
    private_dns_zone_ids = [var.dns_zone_ids.backend]
  }

  # This resource does not literally depend on the CMK. However, if both the CMK and the PE are created at the same time
  # one of them will fail. This is because the workspace is put in an "updating" state during either operation, blocking
  # the other operation.
  depends_on = [azurerm_databricks_workspace_root_dbfs_customer_managed_key.this]

  tags = var.tags
}
