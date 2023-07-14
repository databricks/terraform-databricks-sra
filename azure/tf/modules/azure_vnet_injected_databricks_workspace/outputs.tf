output "workspace_name" {
  value       = azurerm_databricks_workspace.this.name
  description = "Name of the Databricks workspace"
}

output "workspace_id" {
  value       = azurerm_databricks_workspace.this.id
  description = "ID of the Databricks workspace"
}

output "databricks_workspace_id" {
  value       = tonumber(azurerm_databricks_workspace.this.workspace_id)
  description = "ID of the Databricks workspace in the Databricks Control Plane"
}

output "workspace_url" {
  value = azurerm_databricks_workspace.this.workspace_url
}

output "private_subnet_address_prefixes" {
  value = azurerm_subnet.private.address_prefixes
}

output "public_subnet_address_prefixes" {
  value = azurerm_subnet.public.address_prefixes
}
