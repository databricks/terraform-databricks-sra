# Define module "spoke" this should be replicated for any additional spokes you would like to create
module "spoke" {
  source = "./modules/spoke"

<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> cac46f6 (docs(azure): Improve comments and README)
  # Update these per spoke
  resource_suffix = var.spoke_config["spoke"].resource_suffix
  vnet_cidr       = var.spoke_config["spoke"].cidr
  tags            = var.spoke_config["spoke"].tags
=======
  # Pass the required variables to the module
<<<<<<< HEAD
  resource_suffix          = var.spoke_config["spoke"].resource_suffix
  vnet_cidr                = var.spoke_config["spoke"].cidr
  tags                     = var.spoke_config["spoke"].tags
>>>>>>> 791c76c (feat(azure): Remove for_each spoke creation)
=======
  resource_suffix = var.spoke_config["spoke"].resource_suffix
  vnet_cidr       = var.spoke_config["spoke"].cidr
  tags            = var.spoke_config["spoke"].tags
>>>>>>> b2a5a02 (chore(azure): Terraform fmt)

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
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> 5554f06 (feat(azure): Add default catalog for spoke)

module "spoke_catalog" {
  source = "./modules/catalog"

<<<<<<< HEAD
<<<<<<< HEAD
  # Update these per catalog for the catalog's spoke
  catalog_name        = module.spoke.resource_suffix
  dns_zone_ids        = [module.spoke.dns_zone_ids["dfs"]]
=======
  location = var.location

  catalog_name        = module.spoke.resource_suffix
  dns_zone_ids        = [module.spoke.dns_zone_ids["dfs"]]
  metastore_id        = module.hub.metastore_id
>>>>>>> 5554f06 (feat(azure): Add default catalog for spoke)
=======
  # Update these per catalog for the catalog's spoke
  catalog_name        = module.spoke.resource_suffix
  dns_zone_ids        = [module.spoke.dns_zone_ids["dfs"]]
>>>>>>> cac46f6 (docs(azure): Improve comments and README)
  ncc_id              = module.spoke.ncc_id
  resource_group_name = module.spoke.resource_group_name
  resource_suffix     = module.spoke.resource_suffix
  subnet_id           = module.spoke.subnet_ids.privatelink
  tags                = module.spoke.tags

<<<<<<< HEAD
<<<<<<< HEAD
  location     = var.location
  metastore_id = module.hub.metastore_id

=======
>>>>>>> 5554f06 (feat(azure): Add default catalog for spoke)
=======
  location     = var.location
  metastore_id = module.hub.metastore_id

>>>>>>> cac46f6 (docs(azure): Improve comments and README)
  providers = {
    databricks.workspace = databricks.spoke
  }
}
<<<<<<< HEAD
=======
>>>>>>> 791c76c (feat(azure): Remove for_each spoke creation)
=======
>>>>>>> 5554f06 (feat(azure): Add default catalog for spoke)
