### AWS Specific Secrets

resource "databricks_secret" "user" {
  key          = "user"
  string_value = var.account_user
  scope        = module.common.secret_scope_id
}

resource "databricks_secret" "pass" {
  key          = "pass"
  string_value = var.account_pass
  scope        = module.common.secret_scope_id
}

resource "databricks_secret" "use_sp_auth" {
  key          = "use-sp-auth"
  string_value = var.use_sp_auth
  scope        = module.common.secret_scope_id
}

resource "databricks_secret" "client_id" {
  key          = "client-id"
  string_value = var.client_id
  scope        = module.common.secret_scope_id
}

resource "databricks_secret" "client_secret" {
  key          = "client-secret"
  string_value = var.client_secret
  scope        = module.common.secret_scope_id
}
