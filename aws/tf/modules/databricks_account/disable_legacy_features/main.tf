# Terraform Documentation: https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/disable_legacy_features_setting

resource "databricks_disable_legacy_features_setting" "this" {
  disable_legacy_features {
    value = true
  }
}