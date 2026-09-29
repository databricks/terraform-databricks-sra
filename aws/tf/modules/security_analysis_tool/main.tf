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

# The SAT service principal's client-id and client-secret are not managed by Terraform, so the credentials never
# pass through Terraform variables or land in state. Add them to the SAT secret scope after the first apply.

# Stop managing the client-id and client-secret secrets created by earlier versions of this module without deleting
# them, so existing SAT deployments keep working.
removed {
  from = databricks_secret.client_id

  lifecycle {
    destroy = false
  }
}

removed {
  from = databricks_secret.client_secret

  lifecycle {
    destroy = false
  }
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