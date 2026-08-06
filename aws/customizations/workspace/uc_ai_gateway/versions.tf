terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.124.0, < 2.0.0"
    }
  }
  required_version = ">= 1.3.0, < 2.0.0"
}
