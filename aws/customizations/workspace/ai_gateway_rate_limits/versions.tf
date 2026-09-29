terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.121, < 2.0"
    }
  }
  required_version = ">= 1.9, < 2.0"
}
