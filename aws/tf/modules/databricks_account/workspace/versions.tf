terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">=1.81.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">=3.2.3"
    }
    time = {
      source  = "hashicorp/time"
      version = ">=0.12.1"
    }
  }
  required_version = ">=1.0"
}