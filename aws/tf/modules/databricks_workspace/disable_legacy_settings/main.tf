# Terraform Documentation: https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/disable_default_legacy_access

resource "databricks_disable_legacy_access_setting" "access" {
  disable_legacy_access {
    value = true
  }
}

# Terraform Documentation https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/disable_legacy_dbfs_setting

resource "databricks_disable_legacy_dbfs_setting" "dbfs" {
  disable_legacy_dbfs {
    value = true
  }
}