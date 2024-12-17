terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.9.0"
    }

    databricks = {
      source  = "databricks/databricks"
      version = ">=1.29.0"
    }

  }
}
