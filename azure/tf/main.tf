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

  #options
  is_kms_enabled           = true
  is_firewall_enabled      = true
  is_unity_catalog_enabled = true
}

# Define module "spoke" with a for_each loop to iterate over each spoke configuration
module "spoke" {

  for_each = var.spoke_config

  source = "./modules/spoke"

  # Pass the required variables to the module
  resource_suffix = each.value.resource_suffix
  vnet_cidr       = each.value.cidr
  tags            = each.value.tags

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
  ncc_id                  = module.hub.ncc_id

  #options
  is_kms_enabled                   = true
  is_frontend_private_link_enabled = false
  boolean_create_private_dbfs      = true

  depends_on = [module.hub]
}
