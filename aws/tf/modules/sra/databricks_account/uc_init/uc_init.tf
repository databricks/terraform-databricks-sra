// Terraform Documentation: https://registry.terraform.io/providers/databricks/databricks/latest/docs/guides/unity-catalog

// Metastore
resource "databricks_metastore" "this" {
  name          = "${var.resource_prefix}-${var.region}-unity-catalog"
  region        = var.region
  force_destroy = true
}