# EXPLANATION: Module that enables the Security Analysis Tool for workspace configuration monitoring

module "security_analysis_tool" {
  count  = var.enable_security_analysis_tool ? 1 : 0
  source = "./security_analysis_tool/aws"

  providers = {
    databricks = databricks.created_workspace
  }
<<<<<<< HEAD
<<<<<<< HEAD
  
=======

  databricks_url       = module.databricks_mws_workspace.workspace_url
  workspace_id         = module.databricks_mws_workspace.workspace_id
>>>>>>> d598b99 (tf linting, sat integration, audit logs reintegration, additional resource for deployment name, and readme update)
=======
  
>>>>>>> 8eced5b (fix(aws) update naming convention of modules, update test, add required terraform provider)
  account_console_id   = var.databricks_account_id
  client_id            = var.client_id
  client_secret        = var.client_secret
  use_sp_auth          = true
  proxies              = {}
  analysis_schema_name = replace("${var.resource_prefix}-catalog-${module.databricks_mws_workspace.workspace_id}.SAT", "-", "_")
  run_on_serverless    = true

  depends_on = [
    module.databricks_mws_workspace,
    module.uc_catalog
  ]
}