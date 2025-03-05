terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "1.54.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.3"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.12.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.76.0"
    }
  }
}