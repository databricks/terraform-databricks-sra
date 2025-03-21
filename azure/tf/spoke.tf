# Define module "spoke" this should be replicated for any additional spokes you would like to create
module "spoke" {
  source = "./modules/spoke"

  # Pass the required variables to the module
  resource_suffix          = var.spoke_config["spoke"].resource_suffix
  vnet_cidr                = var.spoke_config["spoke"].cidr
  tags                     = var.spoke_config["spoke"].tags

  location                = var.location
  route_table_id          = module.hub.route_table_id
  metastore_id            = module.hub.is_unity_catalog_enabled ? module.hub.metastore_id : var.databricks_metastore_id
  hub_vnet_name           = module.hub.vnet_name
  hub_resource_group_name = module.hub.resource_group_name
  hub_vnet_id             = module.hub.vnet_id
  key_vault_id            = module.hub.key_vault_id
  ipgroup_id              = module.hub.ipgroup_id
  managed_disk_key_id     = module.hub.managed_disk_key_id
  managed_services_key_id = module.hub.managed_services_key_id

  #options
  is_kms_enabled                   = true
  is_frontend_private_link_enabled = false
  boolean_create_private_dbfs      = true

  depends_on = [module.hub]
}

module "spoke_catalog" {
  source = "./modules/catalog"

  location = var.location

  catalog_name        = module.spoke.resource_suffix
  dns_zone_ids        = [module.spoke.dns_zone_ids["dfs"]]
  metastore_id        = module.hub.metastore_id
  ncc_id              = module.spoke.ncc_id
  resource_group_name = module.spoke.resource_group_name
  resource_suffix     = module.spoke.resource_suffix
  subnet_id           = module.spoke.subnet_ids.privatelink
  tags                = module.spoke.tags

  providers = {
    databricks.workspace = databricks.spoke
  }
}
