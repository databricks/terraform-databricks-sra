terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">=1.81.0"
    }
  }
  required_version = ">=1.0"
}

module "common" {
  source               = "../common/"
  account_console_id   = var.account_console_id
  sqlw_id              = var.sqlw_id
  analysis_schema_name = var.analysis_schema_name
  proxies              = var.proxies
  run_on_serverless    = var.run_on_serverless
}
