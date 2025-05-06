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
<<<<<<< Updated upstream:azure/tf/modules/azure_hub/versions.tf

=======
    random = {
      source  = "hashicorp/random"
      version = ">=3.0"
    }
>>>>>>> Stashed changes:azure/tf/modules/hub/versions.tf
  }
}
