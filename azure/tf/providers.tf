provider "azurerm" {
  features {}
  environment     = var.azure_environment
  subscription_id = var.subscription_id
}

provider "azapi" {
  environment     = var.azure_environment
  subscription_id = var.subscription_id
}

# datasources.tf resolves the well-known AzureDataBricks application ID through azuread, so this
# provider must target the same cloud as azurerm/azapi.
provider "azuread" {
  environment = var.azure_environment
}

# host selects the Databricks control plane; azure_environment selects the AAD authority and ARM
# endpoint the SDK uses to mint the token. Both are needed — the provider does not derive the
# account console host from azure_environment.
provider "databricks" {
  host              = local.databricks_account_host
  account_id        = var.databricks_account_id
  azure_environment = var.azure_environment
}

# Used only to pass a workspace-level provider to the external SAT submodule
# (databricks-industry-solutions/security-analysis-tool).
provider "databricks" {
  alias             = "sat"
  host              = var.create_hub && length(module.serverless_workspace) > 0 ? module.serverless_workspace[0].workspace_url : "https://placeholder.azuredatabricks.net"
  azure_environment = var.azure_environment
}

# Workspace-scoped providers for the catalog modules. These use the workspace's real URL as an
# explicit host rather than an account-level provider + provider_config { workspace_id }. The SDK
# derives the per-workspace host from a hardcoded Azure US Gov DNS zone (.databricks.azure.us) that
# is wrong for Evergreen workspaces (.usgov.databricks.azure.us), so we must supply the host directly.
provider "databricks" {
  alias             = "spoke_workspace"
  host              = module.spoke_workspace.workspace_url
  azure_environment = var.azure_environment
}

provider "databricks" {
  alias             = "hub_workspace"
  host              = var.create_hub && length(module.serverless_workspace) > 0 ? module.serverless_workspace[0].workspace_url : "https://placeholder.azuredatabricks.net"
  azure_environment = var.azure_environment
}

# These blocks are not required by terraform, but they are here to silence TFLint warnings
provider "null" {}

provider "time" {}
