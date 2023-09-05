provider "azurerm" {
  features {}
}

provider "databricks" {
  host = module.spoke.workspace_url
}
