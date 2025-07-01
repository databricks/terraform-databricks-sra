terraform {
  required_providers {
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
