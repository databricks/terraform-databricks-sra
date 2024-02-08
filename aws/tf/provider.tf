terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.35.0"
    }
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Owner    = var.resource_owner
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