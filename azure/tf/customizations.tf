locals {
  create_sat_sp     = var.sat_configuration.enabled && var.sat_service_principal.client_id == ""
  sat_client_id     = local.create_sat_sp ? azuread_service_principal.sat[0].client_id : var.sat_service_principal.client_id
  sat_client_secret = local.create_sat_sp ? azuread_service_principal_password.sat[0].value : var.sat_service_principal.client_secret
<<<<<<< HEAD
<<<<<<< HEAD
  sat_workspace     = module.hub
  sat_catalog       = var.sat_configuration.enabled ? module.hub_catalog[0] : {}
=======
>>>>>>> d83f047 (feat(azure): Add support for SAT)
=======
  sat_spoke         = module.spoke
>>>>>>> 791c76c (feat(azure): Remove for_each spoke creation)
}

# ----------------------------------------------------------------------------------------------------------------------
# Service Principal for SAT
<<<<<<< HEAD
# Note: This is separated from the SAT module to allow for a BYO-SP pattern. If the user supplies values for the
# sat_service principal variable, creation will be skipped.

=======
# Note: This is separated from the SAT module to allow for a BYO-SP pattern. If the user supplies values for the sat_service principal variable, creation will be skipped.
>>>>>>> d83f047 (feat(azure): Add support for SAT)
resource "azuread_application_registration" "sat" {
  count = local.create_sat_sp ? 1 : 0

  display_name = var.sat_service_principal.name
}

resource "azuread_service_principal" "sat" {
  count = local.create_sat_sp ? 1 : 0

  client_id = azuread_application_registration.sat[0].client_id
  owners    = [data.azurerm_client_config.current.object_id]
}

resource "azuread_service_principal_password" "sat" {
  count = local.create_sat_sp ? 1 : 0

  service_principal_id = azuread_service_principal.sat[0].id
}

data "azurerm_subscription" "sat" {
  count = local.create_sat_sp ? 1 : 0

  subscription_id = var.subscription_id
}

resource "azurerm_role_assignment" "sat_can_read_subscription" {
  count = local.create_sat_sp ? 1 : 0

  principal_id         = azuread_service_principal.sat[0].object_id
  scope                = data.azurerm_subscription.sat[0].id
  role_definition_name = "Reader"
}

# ----------------------------------------------------------------------------------------------------------------------
<<<<<<< HEAD
<<<<<<< HEAD
=======
=======
module "sat_catalog" {
  source = "./modules/catalog"

  catalog_name        = var.sat_configuration.catalog_name
  location            = var.location
  metastore_id        = module.hub.metastore_id
  dns_zone_ids        = [local.sat_spoke.dns_zone_ids.dfs]
  ncc_id              = local.sat_spoke.ncc_id
  resource_group_name = local.sat_spoke.resource_group_name
  resource_suffix     = "sat"
  subnet_id           = local.sat_spoke.subnet_ids.privatelink
  tags                = local.sat_spoke.tags

  providers = {
    databricks.workspace = databricks.spoke
  }
}
>>>>>>> 791c76c (feat(azure): Remove for_each spoke creation)

>>>>>>> d83f047 (feat(azure): Add support for SAT)
# This is modularized to allow for easy count and provider arguments
module "sat" {
  source = "./modules/sat"
  count  = var.sat_configuration.enabled ? 1 : 0

<<<<<<< HEAD
<<<<<<< HEAD
  # Update this as needed
  catalog_name = local.sat_catalog.catalog_name

  tenant_id                       = data.azurerm_client_config.current.tenant_id
  subscription_id                 = var.subscription_id
  databricks_account_id           = var.databricks_account_id
  schema_name                     = var.sat_configuration.schema_name
  proxies                         = var.sat_configuration.proxies
  run_on_serverless               = var.sat_configuration.run_on_serverless
  service_principal_client_id     = local.sat_client_id
  service_principal_client_secret = local.sat_client_secret
  workspace_id                    = local.sat_workspace.workspace_id

  depends_on = [local.sat_catalog]

  # Change the provider if needed
  providers = {
    databricks = databricks.hub
=======
=======
  tenant_id       = data.azurerm_client_config.current.tenant_id
  subscription_id = var.subscription_id

>>>>>>> 791c76c (feat(azure): Remove for_each spoke creation)
  databricks_account_id           = var.databricks_account_id
  schema_name                     = var.sat_configuration.schema_name
  proxies                         = var.sat_configuration.proxies
  run_on_serverless               = var.sat_configuration.run_on_serverless
  catalog_name                    = module.sat_catalog.catalog_name
  service_principal_client_id     = local.sat_client_id
  service_principal_client_secret = local.sat_client_secret

  workspace_id = local.sat_spoke.workspace_id

  depends_on = [module.spoke]

  providers = {
<<<<<<< HEAD
    databricks = databricks.SAT
>>>>>>> d83f047 (feat(azure): Add support for SAT)
=======
    databricks = databricks.spoke
>>>>>>> 791c76c (feat(azure): Remove for_each spoke creation)
  }
}

# Grant the SP created by SAT the account_admin role
resource "databricks_service_principal_role" "sat_account_admin" {
  count = length(module.sat)

  role                 = "account_admin"
  service_principal_id = module.sat[0].service_principal_id
}

resource "databricks_permission_assignment" "sat_workspace_admin" {
  count = length(module.sat)

  permissions  = ["ADMIN"]
  principal_id = module.sat[0].service_principal_id

<<<<<<< HEAD
  provider = databricks.hub
=======
  provider = databricks.SAT
>>>>>>> d83f047 (feat(azure): Add support for SAT)
}
