terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28, < 7.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.121, < 2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.3, < 4.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.12.1, < 1.0"
    }
  }
  required_version = ">= 1.9, < 2.0"
}
