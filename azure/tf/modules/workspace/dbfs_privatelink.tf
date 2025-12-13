locals {
  dbfs_sa_resource_id = join("", [azurerm_databricks_workspace.this.managed_resource_group_id, "/providers/Microsoft.Storage/storageAccounts/", local.dbfs_name])
}

# Define a private endpoint for the dbfs_dfs resource
resource "azurerm_private_endpoint" "dbfs_dfs" {
  count = var.boolean_create_private_dbfs ? 1 : 0

  name                = "dbfspe-dfs"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.network_configuration.private_endpoint_subnet_id

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
    private_dns_zone_ids = [var.dns_zone_ids.dfs]
  }

  tags       = var.tags
  depends_on = [azurerm_databricks_workspace.this]
}

# Define a private endpoint for the dbfs_blob resource
resource "azurerm_private_endpoint" "dbfspe_blob" {
  count = var.boolean_create_private_dbfs ? 1 : 0

  name                = "dbfs-blob"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.network_configuration.private_endpoint_subnet_id

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
    private_dns_zone_ids = [var.dns_zone_ids.blob]
  }

  tags       = var.tags
  depends_on = [azurerm_databricks_workspace.this]
}

module "ncc_dbfs_blob" {
  source = "../self-approving-pe"
  count  = var.boolean_create_private_dbfs ? 1 : 0

  databricks_account_id            = var.databricks_account_id
  group_id                         = "blob"
  network_connectivity_config_id   = var.ncc_id
  resource_id                      = local.dbfs_sa_resource_id
  network_connectivity_config_name = var.ncc_name
}

module "ncc_dbfs_dfs" {
  source = "../self-approving-pe"
  count  = var.boolean_create_private_dbfs ? 1 : 0

  databricks_account_id            = var.databricks_account_id
  group_id                         = "dfs"
  network_connectivity_config_id   = var.ncc_id
  resource_id                      = local.dbfs_sa_resource_id
  network_connectivity_config_name = var.ncc_name
}

# Access connector for the workspace to use for accessing workspace/dbfs storage
resource "azurerm_databricks_access_connector" "ws" {
  count = var.boolean_create_private_dbfs ? 1 : 0

  # "ws" is used in the name to indicate that this access connector is for workspace storage
  name                = "id-databricks-ws-${var.resource_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  identity {
    type = "SystemAssigned"
  }
  tags = var.tags
}
