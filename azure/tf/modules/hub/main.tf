module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~>0.4"
  suffix  = [var.resource_suffix]
}

# Create hub network infrastructure
module "hub_network" {
  source = "../virtual_network"

  vnet_cidr           = var.vnet_cidr
  resource_suffix     = var.resource_suffix
  tags                = var.tags
  resource_group_name = var.resource_group_name
  location            = var.location

  # Reference resources created in firewall.tf
  route_table_id = azurerm_route_table.this.id
  ipgroup_id     = azurerm_ip_group.this.id

  virtual_network_peerings = var.virtual_network_peerings

  # Constructed explicitly rather than passed wholesale — the virtual_network module declares three
  # zones and terraform errors converting a four-attribute object rather than dropping key_vault.
  private_dns_zone_names = {
    backend = var.private_dns_zone_names.backend
    dfs     = var.private_dns_zone_names.dfs
    blob    = var.private_dns_zone_names.blob
  }

  # The hub workspace (WEBAUTH) is serverless-only and does not require subnets
  workspace_subnets = {
    create          = false
    add_to_ip_group = false
  }

  extra_subnets = {
    AzureFirewallSubnet = {
      name     = "AzureFirewallSubnet"
      new_bits = 26 - split("/", var.vnet_cidr)[1]
    }
  }
}
