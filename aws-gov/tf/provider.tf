terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = " 1.54.0"
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
      Resource = var.resource_prefix
    }
  }
}

provider "databricks" {
  alias         = "mws"
  host          = var.account_console[var.databricks_gov_shard]
  account_id    = var.databricks_account_id
  client_id     = var.client_id
  client_secret = var.client_secret
}