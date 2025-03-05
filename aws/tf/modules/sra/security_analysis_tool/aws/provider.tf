terraform {
  required_providers {
    databricks = {
<<<<<<< HEAD
      source  = "databricks/databricks"
      version = ">=1.54.0"
    }
  }
  required_version = ">=1.0"
=======
      source = "databricks/databricks"
    }
  }
>>>>>>> d598b99 (tf linting, sat integration, audit logs reintegration, additional resource for deployment name, and readme update)
}

module "common" {
  source               = "../common/"
  account_console_id   = var.account_console_id
<<<<<<< HEAD
=======
  workspace_id         = var.workspace_id
>>>>>>> d598b99 (tf linting, sat integration, audit logs reintegration, additional resource for deployment name, and readme update)
  sqlw_id              = var.sqlw_id
  analysis_schema_name = var.analysis_schema_name
  proxies              = var.proxies
  run_on_serverless    = var.run_on_serverless
}
