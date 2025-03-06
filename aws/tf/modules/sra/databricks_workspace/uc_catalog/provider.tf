terraform {
  required_providers {
    databricks = {
<<<<<<< HEAD
<<<<<<< HEAD
      source  = "databricks/databricks"
      version = ">=1.54.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">=3.2.3"
    }
    time = {
      source  = "hashicorp/time"
      version = ">=0.12.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.76.0"
    }
  }
  required_version = ">=1.0"
=======
      source = "databricks/databricks"
=======
      source  = "databricks/databricks"
      version = ">=1.54.0"
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
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.76.0"
    }
  }
<<<<<<< HEAD
>>>>>>> b3e4c6f (aws simplicity update)
=======
  required_version = ">=1.0"
>>>>>>> 8eced5b (fix(aws) update naming convention of modules, update test, add required terraform provider)
}