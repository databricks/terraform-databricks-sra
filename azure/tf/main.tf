locals {
  hub_cidr_prefix     = split("/", var.hub_vnet_cidr)[1]
  firewall_newbits    = 26 - local.hub_cidr_prefix
  webauth_newbits     = 26 - local.hub_cidr_prefix
  privatelink_newbits = 24 - local.hub_cidr_prefix
  testvm_newbits      = 28 - local.hub_cidr_prefix
}

module "subnet_addrs" {
  source  = "hashicorp/subnets/cidr"
  version = "~>1.0"

  base_cidr_block = var.hub_vnet_cidr
  networks = [
    {
      name     = "privatelink"
      new_bits = local.privatelink_newbits
    },
    {
      name     = "firewall"
      new_bits = local.firewall_newbits
    },
    {
      name     = "webauth-host"
      new_bits = local.webauth_newbits
    },
    {
      name     = "webauth-container"
      new_bits = local.webauth_newbits
    },
    {
      name     = "testvm"
      new_bits = local.testvm_newbits
    }
  ]
}
# Define module "hub" with the source "./modules/azure_hub"
# Pass the required variables to the module
module "hub" {
  source             = "./modules/hub"
  location           = var.location
  hub_vnet_cidr      = var.hub_vnet_cidr
  subnet_map         = module.subnet_addrs.network_cidr_blocks
  client_config      = data.azurerm_client_config.current
  databricks_app_reg = data.azuread_service_principal.this
  public_repos       = var.public_repos
  tags               = var.tags
  resource_suffix    = var.hub_resource_suffix

<<<<<<< HEAD
  #options
  is_kms_enabled           = true
  is_firewall_enabled      = true
  is_unity_catalog_enabled = true
=======
  location                = var.location
  hub_vnet_name           = var.hub_vnet_name
  hub_resource_group_name = var.hub_resource_group_name
  hub_vnet_cidr           = var.hub_vnet_cidr
  subnet_map              = module.subnet_addrs.network_cidr_blocks
  public_repos            = var.public_repos
  test_vm_password        = var.test_vm_password
  client_secret           = var.client_secret
  application_id          = var.application_id
  tags                    = var.tags
>>>>>>> 55184a6 (fix missing application_id for sp)
}

module "hub_catalog" {
  source = "./modules/catalog"

  # This catalog is only created if SAT is enabled. If SAT is provisioned in a spoke, this can be manually removed.
  count = var.sat_configuration.enabled ? 1 : 0

  catalog_name        = var.sat_configuration.catalog_name
  location            = var.location
  metastore_id        = module.hub.metastore_id
  dns_zone_ids        = [module.hub.dns_zone_ids.dfs]
  ncc_id              = module.hub.ncc_id
  resource_group_name = module.hub.resource_group_name
  resource_suffix     = "${local.sat_workspace.resource_suffix}sat"
  subnet_id           = module.hub.subnet_ids.privatelink
  tags                = module.hub.tags

  providers = {
    databricks.workspace = databricks.hub
  }
}
