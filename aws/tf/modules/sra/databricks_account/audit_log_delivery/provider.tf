terraform {
  required_providers {
    databricks = {
<<<<<<< HEAD
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
    time = {
      source  = "hashicorp/time"
      version = "0.12.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.76.0"
    }
  }
  required_version = ">=1.0"
=======
      source = "databricks/databricks"
=======
      source  = "databricks/databricks"
      version = "1.54.0"
>>>>>>> ecbeb76 (adding required provider versions)
    }
  }
>>>>>>> d598b99 (tf linting, sat integration, audit logs reintegration, additional resource for deployment name, and readme update)
}
