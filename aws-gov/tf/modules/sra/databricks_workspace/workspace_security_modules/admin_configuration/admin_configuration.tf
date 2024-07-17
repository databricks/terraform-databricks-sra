// Terraform Documentation: https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/workspace_conf

resource "databricks_workspace_conf" "just_config_map" {
  custom_config = {
    "enableResultsDownloading"                         = "false", // https://docs.databricks.com/en/notebooks/notebook-outputs.html#download-results
    "enableNotebookTableClipboard"                     = "false", // https://docs.databricks.com/en/administration-guide/workspace-settings/notebooks.html#enable-users-to-copy-data-to-the-clipboard-from-notebooks
    "enableVerboseAuditLogs"                           = "true",  // https://docs.databricks.com/en/administration-guide/account-settings/verbose-logs.html
    "enableDbfsFileBrowser"                            = "false", // https://docs.databricks.com/en/administration-guide/workspace-settings/dbfs-browser.html
    "enableExportNotebook"                             = "false", // https://docs.databricks.com/en/administration-guide/workspace-settings/notebooks.html#enable-users-to-export-notebooks
    "enforceUserIsolation"                             = "true",  // https://docs.databricks.com/en/administration-guide/workspace-settings/enforce-user-isolation.html
    "storeInteractiveNotebookResultsInCustomerAccount" = "true",  // https://docs.databricks.com/en/administration-guide/workspace-settings/notebooks.html#manage-where-notebook-results-are-stored
    "enableUploadDataUis"                              = "false"  // https://docs.databricks.com/en/ingestion/add-data/index.html
  }
}