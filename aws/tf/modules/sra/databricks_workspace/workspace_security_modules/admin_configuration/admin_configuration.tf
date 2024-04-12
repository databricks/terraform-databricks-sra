// Terraform Documentation: https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/workspace_conf

resource "databricks_workspace_conf" "just_config_map" {
  custom_config = {
    "enableResultsDownloading"      = "false",
    "enableNotebookTableClipboard"  = "false",
    "enableVerboseAuditLogs"        = "true",
    "enable-X-Frame-Options"        = "true",
    "enable-X-Content-Type-Options" = "true",
    "enable-X-XSS-Protection"       = "true",
    "enableDbfsFileBrowser"         = "false",
    "enforceUserIsolation"          = "true",
  }
}