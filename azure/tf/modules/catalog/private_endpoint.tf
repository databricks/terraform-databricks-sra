resource "azurerm_private_endpoint" "dfs" {
  name                = "${module.naming.private_endpoint.name}-dfs"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  # Define the private service connection for the dbfs_dfs resource
  private_service_connection {
    name                           = "${module.naming.private_service_connection.name}-dfs"
    private_connection_resource_id = azurerm_storage_account.unity_catalog.id
    is_manual_connection           = false
    subresource_names              = ["dfs"]
  }

  # Associate the private DNS zone with the private endpoint
  private_dns_zone_group {
    name                 = module.naming.private_dns_zone_group.name
    private_dns_zone_ids = var.dns_zone_ids
  }

  tags = var.tags
}

resource "databricks_mws_ncc_private_endpoint_rule" "dfs" {
  network_connectivity_config_id = var.ncc_id
  resource_id                    = azurerm_storage_account.unity_catalog.id
  group_id                       = "dfs"
}
