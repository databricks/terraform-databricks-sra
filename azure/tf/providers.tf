locals {
  # This can be changed to any spoke, but by default is the first spoke in the spoke_config
  sat_spoke = var.sat_configuration.spoke == "" ? keys(var.spoke_config)[0] : var.sat_configuration.spoke
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "databricks" {
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
  host       = "https://accounts.azuredatabricks.net"
  account_id = var.databricks_account_id
}

provider "databricks" {
<<<<<<< HEAD
  alias = "hub"
  host  = module.hub.workspace_url
}

# Add additional spoke providers as necessary (required for creating a catalog in a spoke)
provider "databricks" {
  alias = "spoke"
  host  = module.spoke.workspace_url
=======
  alias           = "accounts"
  host            = "https://accounts.azuredatabricks.net"
  account_id      = var.databricks_account_id
  azure_tenant_id = "***REMOVED***"
  # auth_type  = "azure-cli"
}

provider "databricks" {
  host            = "https://accounts.azuredatabricks.net"
  account_id      = var.databricks_account_id
  azure_tenant_id = "***REMOVED***"
  # auth_type  = "azure-cli"
>>>>>>> 6df143a (deployed without UC)
=======
  alias      = "accounts"
  host       = "https://accounts.azuredatabricks.net"
  account_id = var.databricks_account_id
}

provider "databricks" {
=======
>>>>>>> 8c62cee (chore: Remove unused accounts provider)
  host       = "https://accounts.azuredatabricks.net"
  account_id = var.databricks_account_id
>>>>>>> dfb2809 (fix: Remove defaulted auth info on Databricks providers)
=======
  alias = "SAT"
  host  = module.spoke[local.sat_spoke].workspace_url
>>>>>>> d83f047 (feat(azure): Add support for SAT)
}
