module "spoke_network" {
  source   = "./modules/spoke_network"
  for_each = var.spoke_config

  location = var.location

  vnet_cidr       = each.value.cidr
  resource_suffix = each.value.resource_suffix
  tags            = each.value.tags

  route_table_id          = var.create_hub ? module.hub[0].route_table_id : each.value.route_table_id
  ipgroup_id              = var.create_hub ? module.hub[0].ipgroup_id : each.value.ipgroup_id
  hub_vnet_name           = var.create_hub ? module.hub[0].vnet_name : each.value.hub_vnet_name
  hub_resource_group_name = var.create_hub ? module.hub[0].resource_group_name : each.value.hub_resource_group_name
  hub_vnet_id             = var.create_hub ? module.hub[0].vnet_id : each.value.hub_vnet_id
}

module "spoke_workspace" {
  source = "./modules/workspace"

  provisioner_principal_id = data.databricks_user.provisioner.id
  databricks_account_id    = var.databricks_account_id
  location                 = var.location

  #TODO: When unified provider releases, remove named keys
  network_configuration        = var.workspace_config["spoke"].spoke_name == null ? var.workspace_config["spoke"].network_configuration : module.spoke_network[var.workspace_config["spoke"].spoke_name].network_configuration
  resource_group_name          = var.workspace_config["spoke"].spoke_name == null ? var.workspace_config["spoke"].resource_group_name : module.spoke_network[var.workspace_config["spoke"].spoke_name].resource_group_name
  resource_suffix              = var.workspace_config["spoke"].spoke_name == null ? var.workspace_config["spoke"].resource_suffix : module.spoke_network[var.workspace_config["spoke"].spoke_name].resource_suffix
  tags                         = var.workspace_config["spoke"].spoke_name == null ? var.workspace_config["spoke"].tags : module.spoke_network[var.workspace_config["spoke"].spoke_name].tags
  dns_zone_ids                 = var.workspace_config["spoke"].spoke_name == null ? var.workspace_config["spoke"].dns_zone_ids : module.spoke_network[var.workspace_config["spoke"].spoke_name].dns_zone_ids
  is_kms_enabled               = var.workspace_config["spoke"].is_kms_enabled
  enhanced_security_compliance = var.workspace_config["spoke"].enhanced_security_compliance

  ncc_id                  = var.create_hub ? module.hub[0].ncc_id : var.workspace_config["spoke"].ncc_id
  ncc_name                = var.create_hub ? module.hub[0].ncc_name : var.workspace_config["spoke"].ncc_name
  managed_disk_key_id     = var.create_hub ? module.hub[0].managed_disk_key_id : var.workspace_config["spoke"].managed_disk_key_id
  managed_services_key_id = var.create_hub ? module.hub[0].managed_services_key_id : var.workspace_config["spoke"].managed_services_key_id
  key_vault_id            = var.create_hub ? module.hub[0].key_vault_id : var.workspace_config["spoke"].key_vault_id
  network_policy_id       = var.create_hub ? module.hub[0].network_policy_id : var.workspace_config["spoke"].network_policy_id
  metastore_id            = var.create_hub ? module.hub[0].metastore_id : var.databricks_metastore_id

  depends_on = [module.spoke_network]
}

module "spoke_catalog" {
  source = "./modules/catalog"

  # Update these per catalog for the catalog's spoke
  catalog_name          = module.spoke_workspace.resource_suffix
  dns_zone_ids          = module.spoke_workspace.dns_zone_ids
  ncc_id                = module.spoke_workspace.ncc_id
  ncc_name              = module.spoke_workspace.ncc_name
  resource_group_name   = module.spoke_workspace.resource_group_name
  resource_suffix       = module.spoke_workspace.resource_suffix
  subnet_id             = module.spoke_workspace.subnet_ids.privatelink
  tags                  = module.spoke_workspace.tags
  databricks_account_id = var.databricks_account_id
  is_default_namespace  = true

  location     = var.location
  metastore_id = var.create_hub ? module.hub[0].metastore_id : var.workspace_config["spoke"].metastore_id

  providers = {
    databricks.workspace = databricks.spoke
  }
}
