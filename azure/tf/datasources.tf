# Retrieve the current Azure client configuration
data "azurerm_client_config" "current" {}

data "azuread_user" "current" {
  object_id = data.azurerm_client_config.current.object_id
}

# Get the application IDs for APIs published by Microsoft
data "azuread_application_published_app_ids" "well_known" {}

# Get the object id of the Azure DataBricks service principal
data "azuread_service_principal" "this" {
  client_id = data.azuread_application_published_app_ids.well_known.result["AzureDataBricks"]
}

data "databricks_user" "provisioner" {
  user_name = data.azuread_user.current.mail
}

# Used to validate that there are enough NCCs left in a region
data "databricks_mws_network_connectivity_configs" "this" {
  region = var.location
}
