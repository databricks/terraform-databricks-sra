module "unity_catalog" {
  source                      = "../../modules/unity_catalog/"
  project       = var.project
  databricks_workspace_ids = var.databricks_workspace_ids
  databricks_workspace_url = var.databricks_workspace_url
  location = var.location
  resource_prefix = var.resource_prefix
}