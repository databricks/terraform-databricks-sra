terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
<<<<<<< HEAD
      version = "~>4.9"
=======
      version = ">=4.9.0"
>>>>>>> f23d215 (update azure provider version to 4.9)
    }
    databricks = {
      source  = "databricks/databricks"
      version = "~>1.66"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~>3.0"
    }
  }
  required_version = "~>1.9"
}
