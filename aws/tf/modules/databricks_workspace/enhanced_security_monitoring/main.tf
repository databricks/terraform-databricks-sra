# Terraform Documentation: https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/enhanced_security_monitoring_workspace_setting

resource "databricks_enhanced_security_monitoring_workspace_setting" "this" {
  enhanced_security_monitoring_workspace {
    is_enabled = true
  }
}