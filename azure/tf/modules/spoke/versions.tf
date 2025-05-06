terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.65.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = ">=1.24.1"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.0"
    }
  }
  required_version = ">=1.9.8"
}
