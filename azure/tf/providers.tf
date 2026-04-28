provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "azapi" {
  subscription_id = var.subscription_id
}

provider "databricks" {
  host       = "https://accounts.azuredatabricks.net"
  account_id = var.databricks_account_id
}

provider "databricks" {
  alias = "hub"
  host  = var.create_hub && length(module.webauth_workspace) > 0 ? module.webauth_workspace[0].workspace_url : "https://placeholder.azuredatabricks.net"
  workspace_id = var.create_hub && length(module.webauth_workspace) > 0 ? module.webauth_workspace[0].workspace_id : null
}

# Spoke provider (required for creating a catalog in the spoke workspace)
provider "databricks" {
  alias = "spoke"
  host  = module.spoke_workspace.workspace_url
  workspace_id = module.spoke_workspace.workspace_id
}

# These blocks are not required by terraform, but they are here to silence TFLint warnings
provider "null" {}

provider "time" {}
