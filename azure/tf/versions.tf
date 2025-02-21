terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
<<<<<<< HEAD
<<<<<<< HEAD
      version = "~>4.9"
=======
      version = ">=4.9.0"
>>>>>>> f23d215 (update azure provider version to 4.9)
=======
      version = "~>4.9"
>>>>>>> 6df143a (deployed without UC)
    }
    databricks = {
      source  = "databricks/databricks"
<<<<<<< HEAD
<<<<<<< HEAD
      version = "~>1.66"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~>3.0"
=======
      version = "~>1.29"
>>>>>>> 6df143a (deployed without UC)
=======
      version = "~>1.66"
>>>>>>> 8d44021 (serverless and classic compute working)
    }
  }
  required_version = "~>1.9"
}
