locals {
  create_sat_sp     = var.sat_configuration.enabled && var.sat_service_principal.client_id == ""
  sat_client_id     = local.create_sat_sp ? azuread_service_principal.sat[0].client_id : var.sat_service_principal.client_id
  sat_client_secret = local.create_sat_sp ? azuread_service_principal_password.sat[0].value : var.sat_service_principal.client_secret
  sat_workspace     = module.hub
}

# ----------------------------------------------------------------------------------------------------------------------
# Service Principal for SAT
# Note: This is separated from the SAT module to allow for a BYO-SP pattern. If the user supplies values for the
# sat_service principal variable, creation will be skipped.

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
# This is modularized to allow for easy count and provider arguments
module "sat" {
  source = "./modules/sat"
  count  = var.sat_configuration.enabled ? 1 : 0

  # Update this as needed
  catalog_name = module.hub_catalog[0].catalog_name

  tenant_id                       = data.azurerm_client_config.current.tenant_id
  subscription_id                 = var.subscription_id
  databricks_account_id           = var.databricks_account_id
  schema_name                     = var.sat_configuration.schema_name
  proxies                         = var.sat_configuration.proxies
  run_on_serverless               = var.sat_configuration.run_on_serverless
  service_principal_client_id     = local.sat_client_id
  service_principal_client_secret = local.sat_client_secret
  workspace_id                    = local.sat_workspace.workspace_id

  depends_on = [module.hub_catalog]

  # Change the provider if needed
  providers = {
    databricks = databricks.hub
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

  provider = databricks.hub
}
