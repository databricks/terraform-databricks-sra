# The value of the "workspace_url" property represents the URL of the Databricks workspace
output "workspace_url" {
  value = azurerm_databricks_workspace.this.workspace_url
}
