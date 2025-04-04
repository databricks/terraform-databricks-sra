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
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> 076f3d9 (feat(azure): Provision webauth workspace as a normal workspace, now supporting SAT)
    random = {
      source  = "hashicorp/random"
      version = ">=3.0"
    }
  }
  required_version = ">=1.9.8"
=======
  }
<<<<<<< HEAD
  required_version = "~>1.9.8"
>>>>>>> 900395d (naming)
=======
  required_version = ">=1.9.8"
>>>>>>> 6df143a (deployed without UC)
}
