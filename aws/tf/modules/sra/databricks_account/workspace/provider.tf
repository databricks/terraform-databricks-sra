terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
<<<<<<< HEAD
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
=======
      version = ">=1.54.0"
>>>>>>> 8eced5b (fix(aws) update naming convention of modules, update test, add required terraform provider)
    }
    null = {
      source  = "hashicorp/null"
      version = ">=3.2.3"
    }
    time = {
      source  = "hashicorp/time"
<<<<<<< HEAD
      version = "0.12.1"
>>>>>>> ecbeb76 (adding required provider versions)
=======
      version = ">=0.12.1"
>>>>>>> 8eced5b (fix(aws) update naming convention of modules, update test, add required terraform provider)
    }
  }
  required_version = ">=1.0"
}