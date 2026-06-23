# Define a Databricks Metastore resource
resource "databricks_metastore" "this" {
  count = var.is_unity_catalog_enabled ? 1 : 0

  name          = "uc-metastore-${var.resource_suffix}"
  region        = var.location
  force_destroy = var.force_destroy
}
