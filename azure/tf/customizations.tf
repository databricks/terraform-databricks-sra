# ----------------------------------------------------------------------------------------------------------------------
# Service Principal for SAT
#
# Note: This is separated from the SAT module to allow for a BYO-SP pattern. Simply remove these resources and replace
# with an existing service principal in the sat module inputs.

resource "azuread_application_registration" "sat" {
  count = var.sat_configuration.enabled ? 1 : 0

  display_name = var.sat_configuration.service_principal_name
}

resource "azuread_service_principal" "sat" {
  count = var.sat_configuration.enabled ? 1 : 0

  client_id = azuread_application_registration.sat[0].client_id
  owners    = [data.azurerm_client_config.current.object_id]
}

resource "azuread_service_principal_password" "sat" {
  count = var.sat_configuration.enabled ? 1 : 0

  service_principal_id = azuread_service_principal.sat[0].id
}
# ----------------------------------------------------------------------------------------------------------------------

# This is modularized to allow for easy count and provider arguments
module "sat" {
  source = "./modules/sat"

  count = var.sat_configuration.enabled ? 1 : 0

  databricks_account_id           = var.databricks_account_id
  schema_name                     = var.sat_configuration.schema_name
  service_principal_client_id     = azuread_service_principal.sat[0].client_id
  service_principal_client_secret = azuread_service_principal_password.sat[0].value
  subscription_id                 = var.subscription_id
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  workspace_id                    = module.spoke[local.sat_spoke].workspace_id
  proxies                         = var.sat_configuration.proxies
  run_on_serverless               = var.sat_configuration.run_on_serverless

  providers = {
    databricks = databricks.SAT
  }
}
