module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~>0.4"
  suffix  = [var.resource_suffix]
}

# Create hub network infrastructure
# This must come AFTER firewall.tf resources (route_table, ipgroup) are created
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

  extra_subnets = {
    AzureFirewallSubnet = {
      name     = "AzureFirewallSubnet"
      new_bits = 26 - split("/", var.vnet_cidr)[1]
    }
  }
}
