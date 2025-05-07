terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = " 1.54.0"
    }
    aws = {
      source  = "hashicorp/aws"
<<<<<<< HEAD
      version = "5.76.0"
=======
      version = " 5.76.0"
>>>>>>> d598b99 (tf linting, sat integration, audit logs reintegration, additional resource for deployment name, and readme update)
    }
  }
  required_version = "~>1.0"
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Resource = var.resource_prefix
    }
  }
}

provider "databricks" {
  alias         = "mws"
  host          = "https://accounts.cloud.databricks.com"
  account_id    = var.databricks_account_id
  client_id     = var.client_id
  client_secret = var.client_secret
}