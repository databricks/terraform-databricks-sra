provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "databricks" {
  alias           = "accounts"
  host            = "https://accounts.azuredatabricks.net"
  account_id      = var.databricks_account_id
  azure_tenant_id = "bf465dc7-3bc8-4944-b018-092572b5c20d"
  # auth_type  = "azure-cli"
}

provider "databricks" {
  host            = "https://accounts.azuredatabricks.net"
  account_id      = var.databricks_account_id
  azure_tenant_id = "bf465dc7-3bc8-4944-b018-092572b5c20d"
  # auth_type  = "azure-cli"
}
