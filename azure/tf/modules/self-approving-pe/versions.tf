terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.65"
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
