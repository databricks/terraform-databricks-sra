module "hub" {

}

module "spoke_vnet" {
  source                              = "../../modules/azure_spoke_vnet"
  project_name                        = var.project_name
  location                            = azurerm_virtual_network.this.location
  hub_vnet_name                       = azurerm_virtual_network.this.name
  hub_resource_group_name             = azurerm_resource_group.this.name
  firewall_private_ip                 = azurerm_firewall.this.ip_configuration[0].private_ip_address
  spoke_vnet_address_space            = var.spoke_vnet_address_space
  spoke_resource_group_name           = var.spoke_resource_group_name
  privatelink_subnet_address_prefixes = var.privatelink_subnet_address_prefixes
  tags                                = var.tags
  depends_on = [
    resource.azurerm_resource_group.this
  ]
}

module "spoke_databricks_workspace" {
  source                          = "../../modules/azure_vnet_injected_databricks_workspace"
  workspace_name                  = var.databricks_workspace_name
  databricks_resource_group_name  = module.spoke_vnet.rg_name
  location                        = azurerm_virtual_network.this.location
  vnet_id                         = module.spoke_vnet.vnet_id
  vnet_name                       = module.spoke_vnet.vnet_name
  nsg_id                          = module.spoke_vnet.nsg_id
  route_table_id                  = module.spoke_vnet.route_table_id
  private_subnet_address_prefixes = var.private_subnet_address_prefixes
  public_subnet_address_prefixes  = var.public_subnet_address_prefixes
  tags                            = var.tags
}


module "unity_catalog" {
  source                  = "../../modules/azure_uc"
  resource_group_id       = azurerm_resource_group.this.id
  workspaces_to_associate = [module.spoke_databricks_workspace.databricks_workspace_id]
}

