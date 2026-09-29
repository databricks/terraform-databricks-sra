# Azure Government deployment.
#
# azure_environment is the only Government-specific setting required. It targets the azurerm, azapi,
# azuread, and databricks providers at Azure Government and derives the Databricks account console
# host and all private DNS zone names (see tf/locals.tf).
azure_environment = "usgovernment"

databricks_account_id = "00000000-0000-0000-0000-000000000000"
subscription_id       = "ffffffff-ffff-ffff-ffff-ffffffffffff"
location              = "usgovvirginia"
hub_resource_suffix   = "srahub"
hub_vnet_cidr         = "10.0.0.0/22"
resource_suffix       = "spoke"
tags = {
  Owner = "john.smith@company.com"
}
workspace_vnet = {
  cidr = "10.0.4.0/22"
}
