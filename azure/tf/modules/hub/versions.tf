terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=5.1.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = ">=1.24.1"
    }
    azapi = {
      source  = "Azure/azapi"
      version = ">=2.0"
    }
  }
  required_version = ">=1.9.8"
}

