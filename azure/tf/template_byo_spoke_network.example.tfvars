databricks_account_id = "00000000-0000-0000-0000-000000000000"
location              = "westus2"
subscription_id       = "ffffffff-ffff-ffff-ffff-ffffffffffff"
resource_suffix       = "spokenonet"

# Hub configuration (SRA-managed)
create_hub = false

# Network mode: BYO spoke network instead of SRA-managed
create_workspace_vnet = false

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

tags = {
  Owner = "john.smith@company.com"
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