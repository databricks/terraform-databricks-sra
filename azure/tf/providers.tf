provider "azurerm" {
  features {}
}

provider "databricks" {
  host = module.spoke_databricks_workspace.workspace_url
}
