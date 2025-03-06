terraform {
  required_providers {
    databricks = {
<<<<<<< HEAD
<<<<<<< HEAD
      source  = "databricks/databricks"
      version = ">=1.54.0"
=======
      source = "databricks/databricks"
>>>>>>> d598b99 (tf linting, sat integration, audit logs reintegration, additional resource for deployment name, and readme update)
=======
      source  = "databricks/databricks"
<<<<<<< HEAD
      version = "1.54.0"
>>>>>>> ecbeb76 (adding required provider versions)
=======
      version = ">=1.54.0"
>>>>>>> 8eced5b (fix(aws) update naming convention of modules, update test, add required terraform provider)
    }
  }
  required_version = ">=1.0"
}