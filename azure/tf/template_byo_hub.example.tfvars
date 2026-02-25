# BYO Hub (no hub created by SRA)
create_hub              = false
create_workspace_vnet   = true
databricks_metastore_id = "00000000-0000-0000-0000-000000000000"

# Basic configuration
location        = "westus2"
subscription_id = "ffffffff-ffff-ffff-ffff-ffffffffffff"
resource_suffix = "spokenonet"

tags = {
  Owner = "user@example.com"
}

workspace_vnet = {
  cidr = "10.1.0.0/24"
}

# Use existing resource group
existing_resource_group_name = "rg-example"

# BYO hub integration (from external hub)
existing_cmk_ids = {
  key_vault_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example-hub/providers/Microsoft.KeyVault/vaults/kv-example-hub"
  managed_disk_key_id     = "https://example-keyvault.vault.azure.net/keys/example/fdf067c93bbb4b22bff4d8b7a9a56217"
  managed_services_key_id = "https://example-keyvault.vault.azure.net/keys/example/fdf067c93bbb4b22bff4d8b7a9a56217"
}

# Existing hub VNET details (for spoke network peering)
existing_hub_vnet = {
  route_table_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-external-hub/providers/Microsoft.Network/routeTables/rt-external"
  vnet_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-external-hub/providers/Microsoft.Network/virtualNetworks/vnet-external-hub"
}

# Optional: Create firewall rules on existing hub firewall for spoke classic compute traffic
# Requires an existing firewall policy ID from your hub. An IP group will be created automatically.
# create_spoke_firewall_rules = true
# existing_firewall_policy_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-external-hub/providers/Microsoft.Network/firewallPolicies/fp-external"

# Optional: Create a Databricks network policy for spoke serverless compute
# existing_ncc_id must still be provided (NCC is a shared regional resource managed by the hub).
# create_spoke_network_policy = true
# existing_ncc_id   = "ncc-00000000-0000-0000-0000-000000000000"
# existing_ncc_name = "ncc-westus2-myhub"

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