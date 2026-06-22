terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.9"
    }
    databricks = {
      source = "databricks/databricks"
      # Version 1.114 released a regression that has yet to be fixed. This pin will be updated when that is fixed.
      version = "<1.114.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~>3.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~>2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~>3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~>0.13"
    }
  }
  required_version = "~>1.11"
}
