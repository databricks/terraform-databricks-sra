terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
      configuration_aliases = [
        databricks.mws
      ]
    }
    aws = {
    source  = "hashicorp/aws"
    }
  }
}

provider "databricks" {
  alias      = "created_workspace"
  host       = module.databricks_mws_workspace.workspace_url
  username   = var.databricks_account_username
  password   = var.databricks_account_password
  auth_type  = "basic"
}