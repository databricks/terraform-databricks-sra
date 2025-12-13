# Create workspace subnets
resource "azurerm_subnet" "workspace_subnets" {
  for_each = local.workspace_subnets

  name                 = "${module.naming.subnet.name}-${each.key}"
  resource_group_name  = azurerm_virtual_network.this.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name

  address_prefixes = [module.subnet_addrs.network_cidr_blocks[each.key]]

  delegation {
    name = "databricks-container-subnet-delegation"

    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
      ]
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "workspace_subnets" {
  for_each = azurerm_subnet.workspace_subnets

  subnet_id                 = each.value.id
  network_security_group_id = azurerm_network_security_group.this.id
}

# Associate the route table with the host subnet
resource "azurerm_subnet_route_table_association" "workspace_subnets" {
  for_each = azurerm_subnet.workspace_subnets

  subnet_id      = each.value.id
  route_table_id = var.route_table_id
}

resource "azurerm_ip_group_cidr" "workspace_subnets" {
  for_each = var.workspace_subnets.add_to_ip_group ? azurerm_subnet.workspace_subnets : {}

  ip_group_id = var.ipgroup_id
  cidr        = each.value.address_prefixes[0]
}

# Create the privatelink subnet
resource "azurerm_subnet" "privatelink" {
  name                 = "${module.naming.subnet.name}-pl"
  resource_group_name  = azurerm_virtual_network.this.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name

  address_prefixes = [module.subnet_addrs.network_cidr_blocks["privatelink"]]
}

# Create any extra subnets
resource "azurerm_subnet" "extra" {
  for_each = var.extra_subnets

  name                 = each.value.name
  resource_group_name  = azurerm_virtual_network.this.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [module.subnet_addrs.network_cidr_blocks[each.value.name]]
}
