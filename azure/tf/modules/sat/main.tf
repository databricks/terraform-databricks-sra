resource "databricks_secret" "client_secret" {
  key          = "client-secret"
  string_value = var.service_principal_client_secret
  scope        = module.sat.secret_scope_id
}

resource "databricks_secret" "subscription_id" {
  key          = "subscription-id"
  string_value = var.subscription_id
  scope        = module.sat.secret_scope_id
}

resource "databricks_secret" "tenant_id" {
  key          = "tenant-id"
  string_value = var.tenant_id
  scope        = module.sat.secret_scope_id
}

resource "databricks_secret" "client_id" {
  key          = "client-id"
  string_value = var.service_principal_client_id
  scope        = module.sat.secret_scope_id
}

data "databricks_group" "admins" {
  display_name = "admins"
}

resource "databricks_service_principal" "sp" {
  application_id = var.service_principal_client_id
  display_name   = "SP for Security Analysis Tool"
}

resource "databricks_group_member" "admin" {
  group_id  = data.databricks_group.admins.id
  member_id = databricks_service_principal.sp.id
}

<<<<<<< HEAD
resource "databricks_grant" "sat_sp_catalog" {
  principal  = databricks_service_principal.sp.application_id
  privileges = ["ALL_PRIVILEGES"]
  catalog    = var.catalog_name
}

module "sat" {
  source = "git::https://github.com/databricks-industry-solutions/security-analysis-tool.git//terraform/common?ref=d57d08288afff59ee14b248d8218d443eae1001e"

  account_console_id   = var.databricks_account_id
  analysis_schema_name = "${var.catalog_name}.${var.schema_name}"
=======
resource "databricks_catalog" "catalog" {
  name = var.catalog_name
}

resource "databricks_grant" "sat_sp_catalog" {
  principal  = databricks_service_principal.sp.application_id
  privileges = ["ALL_PRIVILEGES"]
  catalog    = databricks_catalog.catalog.id
}

module "sat" {
  source = "git::https://github.com/databricks-industry-solutions/security-analysis-tool.git//terraform/common?ref=v0.3.3"

  account_console_id   = var.databricks_account_id
  analysis_schema_name = "${databricks_catalog.catalog.name}.${var.schema_name}"
>>>>>>> d83f047 (feat(azure): Add support for SAT)
  proxies              = var.proxies
  run_on_serverless    = var.run_on_serverless
  workspace_id         = var.workspace_id
}
