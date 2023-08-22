module "hub" {
  source = "./modules/azure_hub"
}

module "spoke" {
  source = "./modules/azure_spoke"

  for_each = {
    for index, spoke in var.spoke_config :
    spoke.prefix => prefix
  }

  prefix = each.value.prefix
  cidr   = each.value.cidr
  tags   = each.value.tags

  location                = var.location
  route_table_id          = module.hub.route_table_id
  metastore_id            = module.hub.metastore_id
  firewall_private_ip     = module.hub.firewall_private_ip
  hub_vnet_name           = module.hub.vnet_name
  hub_resource_group_name = module.hub.resource_group_name
}

# module "unity_catalog" {
#   source                  = "../../modules/azure_uc"
#   resource_group_id       = azurerm_resource_group.this.id
#   workspaces_to_associate = [module.spoke_databricks_workspace.databricks_workspace_id]
# }

