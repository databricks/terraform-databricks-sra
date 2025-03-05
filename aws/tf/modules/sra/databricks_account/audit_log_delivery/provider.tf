terraform {
  required_providers {
    databricks = {
<<<<<<< HEAD
      source  = "databricks/databricks"
      version = ">=1.54.0"
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
    }
  }
>>>>>>> d598b99 (tf linting, sat integration, audit logs reintegration, additional resource for deployment name, and readme update)
}
