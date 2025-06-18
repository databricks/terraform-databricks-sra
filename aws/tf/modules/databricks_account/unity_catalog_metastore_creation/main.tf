# Terraform Documentation: https://registry.terraform.io/providers/databricks/databricks/latest/docs/guides/unity-catalog

# Optional data source - only run if the metastore exists
data "databricks_metastore" "this" {
  count  = var.metastore_exists ? 1 : 0
  region = var.region
}

resource "databricks_metastore" "this" {
  count         = var.metastore_exists ? 0 : 1
  name          = "${var.region}-unity-catalog"
  region        = var.region
  force_destroy = true
}