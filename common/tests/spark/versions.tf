terraform {
  required_version = "~>1.0"
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~>1.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~>0.12"
    }
  }
}

provider "databricks" {
  host = var.databricks_host
}
