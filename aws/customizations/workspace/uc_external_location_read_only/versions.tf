terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">=1.81.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.76.0"
    }
  }
  required_version = ">=1.0"
}