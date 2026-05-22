resource "databricks_secret" "user" {
  key          = "user"
  string_value = var.account_user
  scope        = module.sat.secret_scope_id
}

resource "databricks_secret" "pass" {
  key          = "pass"
  string_value = var.account_pass
  scope        = module.sat.secret_scope_id
}

resource "databricks_secret" "use_sp_auth" {
  key          = "use-sp-auth"
  string_value = var.use_sp_auth
  scope        = module.sat.secret_scope_id
}

resource "databricks_secret" "client_id" {
  key          = "client-id"
  string_value = var.client_id
  scope        = module.sat.secret_scope_id
}

resource "databricks_secret" "client_secret" {
  key          = "client-secret"
  string_value = var.client_secret
  scope        = module.sat.secret_scope_id
}

module "sat" {
  source = "git::https://github.com/databricks-industry-solutions/security-analysis-tool.git//terraform/common?ref=v0.8.0"

  account_console_id              = var.databricks_account_id
  analysis_schema_name            = var.analysis_schema_name
  cloud_type                      = "aws"
  proxies                         = var.proxies
  run_on_serverless               = var.run_on_serverless
  sql_warehouse_enable_serverless = var.sql_warehouse_enable_serverless
  workspace_id                    = var.workspace_id
}