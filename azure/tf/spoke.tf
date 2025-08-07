# Define module "spoke" this should be replicated for any additional spokes you would like to create
module "spoke" {
  source = "./modules/spoke"

  # Update these per spoke
  resource_suffix = var.spoke_config["spoke"].resource_suffix
  vnet_cidr       = var.spoke_config["spoke"].cidr
  tags            = var.spoke_config["spoke"].tags

  location                 = var.location
  route_table_id           = module.hub.route_table_id
  metastore_id             = module.hub.is_unity_catalog_enabled ? module.hub.metastore_id : var.databricks_metastore_id
  hub_vnet_name            = module.hub.vnet_name
  hub_resource_group_name  = module.hub.resource_group_name
  hub_vnet_id              = module.hub.vnet_id
  key_vault_id             = module.hub.key_vault_id
  ipgroup_id               = module.hub.ipgroup_id
  managed_disk_key_id      = module.hub.managed_disk_key_id
  managed_services_key_id  = module.hub.managed_services_key_id
  ncc_id                   = module.hub.ncc_id
  ncc_name                 = module.hub.ncc_name
  network_policy_id        = module.hub.network_policy_id
  provisioner_principal_id = data.databricks_user.provisioner.id
  databricks_account_id    = var.databricks_account_id

  #options
  is_kms_enabled                   = true
  is_frontend_private_link_enabled = false
  boolean_create_private_dbfs      = true

  depends_on = [module.hub]
}

module "spoke_catalog" {
  source = "./modules/catalog"

  # Update these per catalog for the catalog's spoke
  catalog_name          = module.spoke.resource_suffix
  dns_zone_ids          = module.spoke.dns_zone_ids
  ncc_id                = module.spoke.ncc_id
  ncc_name              = module.spoke.ncc_name
  resource_group_name   = module.spoke.resource_group_name
  resource_suffix       = module.spoke.resource_suffix
  subnet_id             = module.spoke.subnet_ids.privatelink
  tags                  = module.spoke.tags
  databricks_account_id = var.databricks_account_id
  is_default_namespace  = true

  location     = var.location
  metastore_id = module.hub.metastore_id

  providers = {
    databricks.workspace = databricks.spoke
  }
}
