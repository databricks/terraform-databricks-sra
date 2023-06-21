terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "1.8.0"
    }
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key  
  default_tags {
    tags = {
    Owner = var.resource_owner
    Resource = var.resource_prefix
    }
  }
}

provider "databricks" {
  alias      = "mws"
  host       = "https://accounts.cloud.databricks.com"
  username   = var.databricks_account_username
  password   = var.databricks_account_password
  auth_type  =  "basic"
}