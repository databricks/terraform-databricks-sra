terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.9"
    }

    databricks = {
      source  = "databricks/databricks"
      version = "~>1.66"
    }
  }
  required_version = "~>1.9"
}
