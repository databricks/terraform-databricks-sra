terraform {
  required_providers {
    databricks = {
<<<<<<< HEAD
<<<<<<< HEAD
      source  = "databricks/databricks"
      version = ">=1.54.0"
    }
  }
  required_version = ">=1.0"
<<<<<<< HEAD
=======
      source = "databricks/databricks"
=======
      source  = "databricks/databricks"
      version = "1.54.0"
>>>>>>> ecbeb76 (adding required provider versions)
    }
  }
>>>>>>> d598b99 (tf linting, sat integration, audit logs reintegration, additional resource for deployment name, and readme update)
=======
>>>>>>> 8eced5b (fix(aws) update naming convention of modules, update test, add required terraform provider)
}