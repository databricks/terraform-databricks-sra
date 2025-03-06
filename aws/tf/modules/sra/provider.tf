terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
<<<<<<< HEAD
<<<<<<< HEAD
      version = ">=1.54.0"
=======
      version = "1.54.0"
>>>>>>> ecbeb76 (adding required provider versions)
=======
      version = ">=1.54.0"
>>>>>>> 8eced5b (fix(aws) update naming convention of modules, update test, add required terraform provider)
      configuration_aliases = [
        databricks.mws
      ]
    }
    aws = {
      source  = "hashicorp/aws"
<<<<<<< HEAD
<<<<<<< HEAD
      version = ">=5.76.0"
=======
      version = "5.76.0"
>>>>>>> ecbeb76 (adding required provider versions)
=======
      version = ">=5.76.0"
>>>>>>> 8eced5b (fix(aws) update naming convention of modules, update test, add required terraform provider)
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