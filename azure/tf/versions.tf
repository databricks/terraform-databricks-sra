terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.78.0"
    }

    databricks = {
      source  = "databricks/databricks"
      version = ">=1.29.0"
    }

  }
}
