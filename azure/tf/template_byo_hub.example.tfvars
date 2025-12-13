# BYO Hub (no hub created by SRA)
create_hub              = false
create_workspace_vnet   = false
databricks_metastore_id = "00000000-0000-0000-0000-000000000000"

# Basic configuration
location        = "westus2"
subscription_id = "ffffffff-ffff-ffff-ffff-ffffffffffff"
resource_suffix = "spokenonet"

tags = {
  Owner = "user@example.com"
}

# BYO workspace network configuration
existing_workspace_vnet = {
  network_configuration = {
    virtual_network_id                                   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example"
    private_subnet_id                                    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/container"
    public_subnet_id                                     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/host"
    private_subnet_network_security_group_association_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/container"
    public_subnet_network_security_group_association_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/host"
    private_endpoint_subnet_id                           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/private-endpoints"
  }
  dns_zone_ids = {
    backend = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/privateDnsZones/privatelink.azuredatabricks.net"
    dfs     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/privateDnsZones/privatelink.dfs.core.windows.net"
    blob    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
  }
}

# Use existing resource group
existing_resource_group_name = "rg-example"

# BYO hub integration (from external hub)
hub_settings = {
  ncc_id                  = "00000000-0000-0000-0000-000000000000"
  ncc_name                = "ncc-example-region"
  network_policy_id       = "np-example-restrictive"
  key_vault_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example-hub/providers/Microsoft.KeyVault/vaults/kv-example-hub"
  managed_disk_key_id     = "https://example-keyvault.vault.azure.net/keys/example/fdf067c93bbb4b22bff4d8b7a9a56217"
  managed_services_key_id = "https://example-keyvault.vault.azure.net/keys/example/fdf067c93bbb4b22bff4d8b7a9a56217"
}

# Existing hub VNET details (for spoke network peering)
existing_hub_vnet = {
  route_table_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-external-hub/providers/Microsoft.Network/routeTables/rt-external"
  vnet_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-external-hub/providers/Microsoft.Network/virtualNetworks/vnet-external-hub"
}

# Network egress configuration
allowed_fqdns    = []
hub_allowed_urls = []

# Optional: Disable customer-managed keys if needed (defaults to enabled)
# cmk_enabled = false

# Optional: Enhanced security compliance
# workspace_security_compliance = {
#   automatic_cluster_update_enabled = true
#   compliance_security_profile_enabled = true
# }