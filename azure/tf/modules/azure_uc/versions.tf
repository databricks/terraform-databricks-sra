terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.43.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = ">=1.9.2"
    }
  }
}
