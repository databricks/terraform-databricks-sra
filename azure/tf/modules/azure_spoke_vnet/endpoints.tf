resource "azurerm_subnet" "privatelink" {
  name                 = "privatelink-subnet-${var.project_name}"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name

  address_prefixes                               = var.privatelink_subnet_address_prefixes
  private_endpoint_network_policies_enabled      = true
}

resource "random_string" "suffix" {
  length  = 5
  special = false
  upper   = false
}

resource "azurerm_storage_account" "this" {
  name                     = "storage${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_replication_type = "RAGRS"
  account_tier             = "Standard"
}

resource "azurerm_private_dns_zone" "storage" {
  name                = "privatelink.dfs.core.windows.net"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage" {
  name                  = "vnet-link"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.storage.name
  virtual_network_id    = azurerm_virtual_network.this.id
}

resource "azurerm_private_endpoint" "storage" {
  name                = "endpoint-storage-${var.project_name}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  subnet_id           = azurerm_subnet.privatelink.id

  private_service_connection {
    name                           = "${azurerm_storage_account.this.name}-pe-connection"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.this.id
    subresource_names              = ["dfs"]
  }

  private_dns_zone_group {
    name                 = "privatelink.dfs.core.windows.net"
    private_dns_zone_ids = [azurerm_private_dns_zone.storage.id]
  }

  depends_on = [
    resource.azurerm_subnet.privatelink,
    resource.azurerm_virtual_network.this
  ]
}

resource "azurerm_private_dns_a_record" "this" {
  name                = "endpoint-storage-arecord"
  zone_name           = azurerm_private_dns_zone.storage.name
  resource_group_name = azurerm_resource_group.this.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.storage.private_service_connection.0.private_ip_address]
}
