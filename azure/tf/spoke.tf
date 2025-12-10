resource "azurerm_resource_group" "spoke" {
  for_each = var.spoke_config

  location = var.location
  name     = "rg-${each.value.resource_suffix}"
  tags     = each.value.tags
}

module "spoke_network" {
  source   = "./modules/virtual_network"
  for_each = var.spoke_config

  vnet_cidr           = each.value.cidr
  resource_suffix     = each.value.resource_suffix
  tags                = each.value.tags
  resource_group_name = azurerm_resource_group.spoke[each.key].name
  location            = var.location

  route_table_id           = var.create_hub ? module.hub[0].route_table_id : each.value.route_table_id
  ipgroup_id               = var.create_hub ? module.hub[0].ipgroup_id : each.value.ipgroup_id
  virtual_network_peerings = var.create_hub ? { hub = { remote_virtual_network_id = module.hub[0].vnet_id } } : {} #TODO: Implement false scenario
  workspace_subnets = {
    new_bits        = each.value.new_bits,
    add_to_ip_group = var.create_hub
  }
}

module "spoke_workspace" {
  source   = "./modules/workspace"
  for_each = var.workspace_config

  provisioner_principal_id = data.databricks_user.provisioner.id
  databricks_account_id    = var.databricks_account_id
  location                 = var.location

  network_configuration        = each.value.spoke_name == null ? each.value.network_configuration : module.spoke_network[each.value.spoke_name].network_configuration
  dns_zone_ids                 = each.value.spoke_name == null ? each.value.dns_zone_ids : module.spoke_network[each.value.spoke_name].dns_zone_ids
  resource_group_name          = each.value.spoke_name == null ? each.value.resource_group_name : azurerm_resource_group.spoke[each.value.spoke_name].name
  resource_suffix              = each.value.spoke_name == null ? each.value.resource_suffix : module.spoke_network[each.value.spoke_name].resource_suffix
  tags                         = each.value.spoke_name == null ? each.value.tags : module.spoke_network[each.value.spoke_name].tags
  enhanced_security_compliance = each.value.enhanced_security_compliance
  name_overrides               = each.value.name_overrides

  # Account level settings
  ncc_id            = var.create_hub ? module.hub[0].ncc_id : each.value.ncc_id
  ncc_name          = var.create_hub ? module.hub[0].ncc_name : each.value.ncc_name
  network_policy_id = var.create_hub ? module.hub[0].network_policy_id : each.value.network_policy_id
  metastore_id      = var.create_hub ? module.hub[0].metastore_id : var.databricks_metastore_id

  # KMS Settings
  is_kms_enabled          = each.value.is_kms_enabled
  managed_disk_key_id     = var.create_hub ? module.hub[0].managed_disk_key_id : each.value.managed_disk_key_id
  managed_services_key_id = var.create_hub ? module.hub[0].managed_services_key_id : each.value.managed_services_key_id
  key_vault_id            = var.create_hub ? module.hub[0].key_vault_id : each.value.key_vault_id
}

#TODO: The below resources are temporary until the unified provider releases. At that time, they will be merged in to
# the workspace module.
resource "databricks_disable_legacy_dbfs_setting" "spoke" {
  disable_legacy_dbfs {
    value = true
  }

  depends_on = [module.spoke_workspace]
  provider   = databricks.spoke
}

resource "databricks_disable_legacy_access_setting" "spoke" {
  disable_legacy_access {
    value = true
  }

  depends_on = [module.spoke_workspace]
  provider   = databricks.spoke
}


module "spoke_catalog" {
  source = "./modules/catalog"

  # Update these per catalog for the catalog's spoke
  catalog_name         = module.spoke_workspace["spoke"].resource_suffix
  is_default_namespace = true

  # Azure/Network settings
  dns_zone_ids        = module.spoke_workspace["spoke"].dns_zone_ids
  location            = var.location
  resource_group_name = module.spoke_workspace["spoke"].resource_group_name
  resource_suffix     = module.spoke_workspace["spoke"].resource_suffix
  subnet_id           = module.spoke_workspace["spoke"].subnet_ids.privatelink
  tags                = module.spoke_workspace["spoke"].tags

  # Account level settings
  databricks_account_id = var.databricks_account_id
  metastore_id          = var.create_hub ? module.hub[0].metastore_id : var.databricks_metastore_id
  ncc_id                = module.spoke_workspace["spoke"].ncc_id
  ncc_name              = module.spoke_workspace["spoke"].ncc_name

  providers = {
    databricks.workspace = databricks.spoke
  }
}
