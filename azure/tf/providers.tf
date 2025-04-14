provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "databricks" {
  host       = "https://accounts.azuredatabricks.net"
  account_id = var.databricks_account_id
}

provider "databricks" {
  alias = "hub"
  host  = module.hub.workspace_url
}

provider "databricks" {
  alias = "spoke"
  host  = module.spoke.workspace_url
}
