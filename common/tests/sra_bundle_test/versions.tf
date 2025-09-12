terraform {
  required_version = ">=1.9.8"
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~>3.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "~>1.0"
    }
  }
}
