# Define module "hub" with the source "./modules/azure_hub"
# Pass the required variables to the module
module "hub" {
  source = "./modules/azure_hub"

  location                = var.location
  hub_vnet_name           = var.hub_vnet_name
  hub_resource_group_name = var.hub_resource_group_name
  hub_vnet_cidr           = var.hub_vnet_cidr
  public_repos            = var.public_repos
  test_vm_password        = var.test_vm_password
  tags                    = var.tags
}

# Define module "spoke" with a for_each loop to iterate over each spoke configuration
module "spoke" {
  for_each = {
    for index, spoke in var.spoke_config : spoke.prefix => spoke
  }

  source = "./modules/azure_spoke"

  # Pass the required variables to the module
  prefix    = each.value.prefix
  vnet_cidr = each.value.cidr
  tags      = each.value.tags

  location                = var.location
  route_table_id          = module.hub.route_table_id
  metastore_id            = module.hub.metastore_id
  hub_vnet_name           = module.hub.vnet_name
  hub_resource_group_name = module.hub.resource_group_name
  hub_vnet_id             = module.hub.vnet_id
  key_vault_id            = module.hub.key_vault_id
  ipgroup_id              = module.hub.ipgroup_id
  managed_disk_key_id     = module.hub.managed_disk_key_id
  managed_services_key_id = module.hub.managed_services_key_id
}
