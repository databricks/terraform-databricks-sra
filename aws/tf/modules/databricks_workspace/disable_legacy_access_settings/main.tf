# Terraform Documentation: https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/disable_default_legacy_access

resource "databricks_disable_legacy_access_setting" "this" {
  disable_legacy_access {
    value = true
  }
}