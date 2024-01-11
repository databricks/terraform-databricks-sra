terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
      configuration_aliases = [
        databricks.mws
      ]
    }
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "databricks" {
  alias         = "created_workspace"
  host          = module.databricks_mws_workspace.workspace_url
  account_id    = var.databricks_account_id
  client_id     = var.client_id
  client_secret = var.client_secret
}