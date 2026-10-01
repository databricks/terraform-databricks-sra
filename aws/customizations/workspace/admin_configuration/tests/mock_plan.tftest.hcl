mock_provider "databricks" {}

# Plans the hardened workspace configuration: data exfiltration paths (results download, clipboard, notebook export,
# DBFS browser, upload UIs) are disabled, and verbose audit logs, user isolation, and customer-account storage of
# notebook results are enabled.
run "plan_valid_configuration" {
  command = plan

  assert {
    condition = alltrue([
      for key in ["enableDbfsFileBrowser", "enableExportNotebook", "enableNotebookTableClipboard", "enableResultsDownloading", "enableUploadDataUis"] :
      databricks_workspace_conf.just_config_map.custom_config[key] == "false"
    ])
    error_message = "Results download, clipboard copy, notebook export, the DBFS browser, and upload UIs must be disabled."
  }

  assert {
    condition = alltrue([
      for key in ["enableVerboseAuditLogs", "enforceUserIsolation", "storeInteractiveNotebookResultsInCustomerAccount"] :
      databricks_workspace_conf.just_config_map.custom_config[key] == "true"
    ])
    error_message = "Verbose audit logs, user isolation, and customer-account notebook result storage must be enabled."
  }
}
