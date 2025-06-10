terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">=1.81.0"
      configuration_aliases = [
        databricks.mws
      ]
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.76.0"
    }
  }
  required_version = ">=1.0"
}

provider "databricks" {
  alias         = "created_workspace"
  host          = module.databricks_mws_workspace.workspace_url
  account_id    = var.databricks_account_id
  client_id     = var.client_id
  client_secret = var.client_secret
}