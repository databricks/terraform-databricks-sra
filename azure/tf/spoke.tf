locals {
  resource_group_name = var.create_workspace_resource_group ? azurerm_resource_group.spoke[0].name : var.existing_resource_group_name
}

resource "azurerm_resource_group" "spoke" {
  count = var.create_workspace_resource_group ? 1 : 0

  location = var.location
  name     = "rg-${var.resource_suffix}"
  tags     = var.tags
}

module "spoke_network" {
  source = "./modules/virtual_network"
  count  = var.workspace_vnet != null ? 1 : 0

  # Azure Parameters
  resource_suffix     = var.resource_suffix
  tags                = var.tags
  resource_group_name = local.resource_group_name
  location            = var.location

  # Networking Parameters
  vnet_cidr                = var.workspace_vnet.cidr
  route_table_id           = var.create_hub ? module.hub[0].route_table_id : var.existing_hub_vnet.route_table_id
  ipgroup_id               = var.create_hub ? module.hub[0].ipgroup_id : null
  virtual_network_peerings = var.create_hub ? { hub = { remote_virtual_network_id = module.hub[0].vnet_id } } : { hub = { remote_virtual_network_id = var.existing_hub_vnet.vnet_id } }
  workspace_subnets = {
    new_bits        = var.workspace_vnet.new_bits
    add_to_ip_group = var.create_hub
  }
}

module "spoke_workspace" {
  source = "./modules/workspace"

  # Azure/Network parameters
  location                     = var.location
  resource_suffix              = var.resource_suffix
  resource_group_name          = local.resource_group_name
  tags                         = var.tags
  enhanced_security_compliance = var.workspace_security_compliance
  name_overrides               = var.workspace_name_overrides
  network_configuration        = var.create_workspace_vnet ? module.spoke_network[0].network_configuration : var.existing_workspace_vnet.network_configuration
  dns_zone_ids                 = var.create_workspace_vnet ? module.spoke_network[0].dns_zone_ids : var.existing_workspace_vnet.dns_zone_ids

  # KMS parameters
  is_kms_enabled          = var.cmk_enabled
  managed_disk_key_id     = local.cmk_managed_disk_key_id
  managed_services_key_id = local.cmk_managed_services_key_id
  key_vault_id            = local.cmk_keyvault_id

  # Account parameters
  ncc_id                   = var.create_hub ? module.hub[0].ncc_id : var.existing_ncc_id
  ncc_name                 = var.create_hub ? module.hub[0].ncc_name : var.existing_ncc_name
  network_policy_id        = var.create_hub ? module.hub[0].network_policy_id : var.existing_network_policy_id
  metastore_id             = var.create_hub ? module.hub[0].metastore_id : var.databricks_metastore_id
  provisioner_principal_id = data.azurerm_client_config.current.object_id
  databricks_account_id    = var.databricks_account_id
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

  catalog_name         = module.spoke_workspace.resource_suffix
  is_default_namespace = true

  # Azure/Network parameters
  dns_zone_ids        = module.spoke_workspace.dns_zone_ids
  location            = var.location
  resource_group_name = module.spoke_workspace.resource_group_name
  resource_suffix     = module.spoke_workspace.resource_suffix
  subnet_id           = module.spoke_workspace.subnet_ids.privatelink
  tags                = module.spoke_workspace.tags

  # Account parameters
  databricks_account_id = var.databricks_account_id
  metastore_id          = var.create_hub ? module.hub[0].metastore_id : var.databricks_metastore_id
  ncc_id                = module.spoke_workspace.ncc_id
  ncc_name              = module.spoke_workspace.ncc_name

  force_destroy = var.catalog_force_destroy

  providers = {
    databricks.workspace = databricks.spoke
  }
}
