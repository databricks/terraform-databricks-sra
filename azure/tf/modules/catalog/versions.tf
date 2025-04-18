terraform {
  required_providers {
    databricks = {
      source                = "databricks/databricks"
      version               = ">=1.0"
      configuration_aliases = [databricks.workspace]
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0"
    }
  }
  required_version = ">=1.0"
}
