terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
<<<<<<< HEAD
      version = ">=1.54.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">=3.2.3"
    }
    time = {
      source  = "hashicorp/time"
      version = ">=0.12.1"
=======
      version = "1.54.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.3"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.12.1"
>>>>>>> ecbeb76 (adding required provider versions)
    }
  }
  required_version = ">=1.0"
}