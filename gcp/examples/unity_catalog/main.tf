module "unity_catalog" {
  source                      = "../../modules/unity_catalog/"
  project       = var.project
  databricks_workspace_ids = var.databricks_workspace_ids
  databricks_workspace_url = var.databricks_workspace_url
  location = var.location
  resource_prefix = var.resource_prefix
  databricks_google_service_account = var.databricks_google_service_account
  databricks_account_id = var.databricks_account_id
  account_console_url = var.account_console_url
  data_access = var.data_access
  existing_metastore_id=var.existing_metastore_id
  databricks_workspace_ids_for_existing_metastore = var.databricks_workspace_ids_for_existing_metastore
}