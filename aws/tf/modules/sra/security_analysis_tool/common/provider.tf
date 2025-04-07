terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">=1.54.0"
    }
  }
  required_version = ">=1.0"
}