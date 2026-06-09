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

# Used only to pass a workspace-level provider to the external SAT submodule
# (databricks-industry-solutions/security-analysis-tool).
provider "databricks" {
  alias = "sat"
  host  = var.create_hub && length(module.webauth_workspace) > 0 ? module.webauth_workspace[0].workspace_url : "https://placeholder.azuredatabricks.net"
}

# These blocks are not required by terraform, but they are here to silence TFLint warnings
provider "null" {}

provider "time" {}
