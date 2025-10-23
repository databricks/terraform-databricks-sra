locals {
  hub_cidr_prefix     = var.create_hub ? split("/", var.hub_vnet_cidr)[1] : 0
  firewall_newbits    = var.create_hub ? 26 - local.hub_cidr_prefix : 0
  webauth_newbits     = var.create_hub ? 26 - local.hub_cidr_prefix : 0
  privatelink_newbits = var.create_hub ? 24 - local.hub_cidr_prefix : 0
  testvm_newbits      = var.create_hub ? 28 - local.hub_cidr_prefix : 0
}

module "subnet_addrs" {
  source  = "hashicorp/subnets/cidr"
  version = "~>1.0"
  count   = var.create_hub ? 1 : 0

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

# Define module "hub" with the source "./modules/hub"
# Pass the required variables to the module
module "hub" {
  source = "./modules/hub"
  count  = var.create_hub ? 1 : 0

  databricks_account_id    = var.databricks_account_id
  hub_allowed_urls         = var.hub_allowed_urls
  hub_vnet_cidr            = var.hub_vnet_cidr
  location                 = var.location
  public_repos             = var.public_repos
  resource_suffix          = var.hub_resource_suffix
  subnet_map               = module.subnet_addrs[0].network_cidr_blocks
  is_kms_enabled           = true
  is_firewall_enabled      = true
  client_config            = data.azurerm_client_config.current
  databricks_app_reg       = data.azuread_service_principal.this
  is_unity_catalog_enabled = true
  tags                     = var.tags
}

module "webauth_workspace" {
  source = "./modules/workspace"
  count  = var.create_hub ? 1 : 0

  network_configuration = {
    virtual_network_name                                 = module.hub[0].vnet_name
    private_subnet_name                                  = module.hub[0].subnet_names.container
    public_subnet_name                                   = module.hub[0].subnet_names.host
    private_subnet_network_security_group_association_id = module.hub[0].private_subnet_network_security_group_association_id
    public_subnet_network_security_group_association_id  = module.hub[0].public_subnet_network_security_group_association_id
    private_endpoint_subnet_name                         = module.hub[0].subnet_names.privatelink
  }

  resource_group_name      = module.hub[0].resource_group_name
  resource_suffix          = module.hub[0].resource_suffix
  tags                     = module.hub[0].tags
  ncc_id                   = module.hub[0].ncc_id
  ncc_name                 = module.hub[0].ncc_name
  location                 = var.location
  dns_zone_ids             = module.hub[0].dns_zone_ids
  managed_disk_key_id      = module.hub[0].managed_disk_key_id
  managed_services_key_id  = module.hub[0].managed_services_key_id
  provisioner_principal_id = data.databricks_user.provisioner.id
  databricks_account_id    = var.databricks_account_id
  key_vault_id             = module.hub[0].key_vault_id
  network_policy_id        = module.hub[0].network_policy_id
  metastore_id             = module.hub[0].metastore_id

  depends_on = [module.hub]
}

module "hub_catalog" {
  source = "./modules/catalog"

  # This catalog is only created if SAT is enabled. If SAT is provisioned in a spoke, this can be manually removed.
  count = var.sat_configuration.enabled && var.create_hub ? 1 : 0

  catalog_name          = var.sat_configuration.catalog_name
  location              = var.location
  metastore_id          = module.hub[0].metastore_id
  dns_zone_ids          = module.hub[0].dns_zone_ids
  ncc_id                = module.hub[0].ncc_id
  ncc_name              = module.hub[0].ncc_name
  resource_group_name   = module.hub[0].resource_group_name
  resource_suffix       = "${local.sat_workspace.resource_suffix}sat"
  subnet_id             = module.hub[0].subnet_ids.privatelink
  tags                  = module.hub[0].tags
  force_destroy         = var.sat_force_destroy
  databricks_account_id = var.databricks_account_id
  is_default_namespace  = true

  providers = {
    databricks.workspace = databricks.hub
  }
}
