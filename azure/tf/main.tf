resource "azurerm_resource_group" "hub" {
  count = var.create_hub ? 1 : 0

  location = var.location
  name     = "rg-${var.hub_resource_suffix}"
  tags     = var.tags
}

# Define module "hub" with the source "./modules/hub"
# Pass the required variables to the module
module "hub" {
  source = "./modules/hub"
  count  = var.create_hub ? 1 : 0

  # Network configuration
  vnet_cidr                = var.hub_vnet_cidr
  virtual_network_peerings = var.workspace_vnet != null ? { spoke = { remote_virtual_network_id = module.spoke_network[0].vnet_id } } : {}

  # Account configuration
  databricks_account_id    = var.databricks_account_id
  hub_allowed_urls         = var.hub_allowed_urls
  location                 = var.location
  public_repos             = var.allowed_fqdns
  resource_suffix          = var.hub_resource_suffix
  is_kms_enabled           = true
  is_firewall_enabled      = true
  client_config            = data.azurerm_client_config.current
  databricks_app_reg       = data.azuread_service_principal.this
  is_unity_catalog_enabled = true
  tags                     = var.tags
  resource_group_name      = azurerm_resource_group.hub[0].name
}

module "webauth_workspace" {
  source = "./modules/workspace"
  count  = var.create_hub ? 1 : 0

  provisioner_principal_id = data.azurerm_client_config.current.object_id
  databricks_account_id    = var.databricks_account_id
  location                 = var.location

  network_configuration = module.hub[0].network_configuration
  dns_zone_ids          = module.hub[0].dns_zone_ids
  resource_group_name   = azurerm_resource_group.hub[0].name
  resource_suffix       = module.hub[0].resource_suffix
  tags                  = module.hub[0].tags
  name_overrides = {
    "databricks_workspace" = "WEBAUTH_DO_NOT_DELETE_${upper(var.location)}"
  }

  # Account level settings
  ncc_id            = module.hub[0].ncc_id
  ncc_name          = module.hub[0].ncc_name
  network_policy_id = module.hub[0].network_policy_id
  metastore_id      = module.hub[0].metastore_id

  # KMS Settings
  is_kms_enabled          = true
  managed_disk_key_id     = module.hub[0].managed_disk_key_id
  managed_services_key_id = module.hub[0].managed_services_key_id
  key_vault_id            = module.hub[0].key_vault_id

  depends_on = [module.hub]
}

#TODO: The below resources are temporary until the unified provider releases. At that time, they will be merged in to
# the workspace module.
resource "databricks_disable_legacy_dbfs_setting" "webauth" {
  count = var.create_hub ? 1 : 0

  disable_legacy_dbfs {
    value = true
  }

  depends_on = [module.webauth_workspace]
  provider   = databricks.hub
}

resource "databricks_disable_legacy_access_setting" "webauth" {
  count = var.create_hub ? 1 : 0

  disable_legacy_access {
    value = true
  }

  depends_on = [module.webauth_workspace]
  provider   = databricks.hub
}

module "hub_catalog" {
  source = "./modules/catalog"

  # This catalog is only created if SAT is enabled. If SAT is provisioned in a spoke, this can be manually removed.
  count = var.sat_configuration.enabled && var.create_hub ? 1 : 0

  catalog_name         = var.sat_configuration.catalog_name
  is_default_namespace = true

  # Azure/Network settings
  dns_zone_ids        = module.webauth_workspace[0].dns_zone_ids
  location            = var.location
  resource_group_name = azurerm_resource_group.hub[0].name
  resource_suffix     = "${local.sat_workspace.resource_suffix}sat"
  subnet_id           = module.hub[0].subnet_ids["privatelink"]
  tags                = module.hub[0].tags

  # Account level settings
  databricks_account_id = var.databricks_account_id
  metastore_id          = module.hub[0].metastore_id
  ncc_id                = module.hub[0].ncc_id
  ncc_name              = module.hub[0].ncc_name

  force_destroy = var.sat_force_destroy

  providers = {
    databricks.workspace = databricks.hub
  }
}
