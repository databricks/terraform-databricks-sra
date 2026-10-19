# Terraform Documentation: https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/disable_legacy_access_setting

# These settings are locked on workspaces created while disable_legacy_features is enabled at the account level, and
# deleting them fails. The root module skips this module for such workspaces (see
# terraform_data.disable_legacy_settings_decision). A locked workspace deployed before that check existed still has
# these resources in state; remove them before terraform destroy:
#   terraform state rm 'module.disable_legacy_settings[0].databricks_disable_legacy_access_setting.access'
#   terraform state rm 'module.disable_legacy_settings[0].databricks_disable_legacy_dbfs_setting.dbfs'

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
