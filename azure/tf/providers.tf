locals {
  # This can be changed to any spoke, but by default is the first spoke in the spoke_config
  sat_spoke = var.sat_configuration.spoke == "" ? keys(var.spoke_config)[0] : var.sat_configuration.spoke
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "databricks" {
  host       = "https://accounts.azuredatabricks.net"
  account_id = var.databricks_account_id
}

provider "databricks" {
  alias = "SAT"
  host  = module.spoke[local.sat_spoke].workspace_url
}
