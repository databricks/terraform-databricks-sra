# Define a Databricks Metastore resource
resource "databricks_metastore" "this" {
  count = var.is_unity_catalog_enabled ? 1 : 0

  name = "uc-metastore-${var.resource_suffix}"
  # owner         = "uc admins"
  region        = azurerm_resource_group.this.location
  force_destroy = true
}

resource "databricks_group" "this" {
  count = var.is_unity_catalog_enabled ? 1 : 0

  display_name = "${var.resource_suffix}-uc-owners"
}
