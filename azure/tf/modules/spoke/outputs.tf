# The value of the "workspace_url" property represents the URL of the Databricks workspace
output "workspace_url" {
  description = "The URL of the Databricks workspace, used to access the Databricks environment."
  value       = azurerm_databricks_workspace.this.workspace_url
}

output "workspace_id" {
  value       = azurerm_databricks_workspace.this.workspace_id
  description = "Workspace ID of the created workspace, according to the Databricks account console"
}

output "id" {
  value       = azurerm_databricks_workspace.this.id
  description = "Azure ID of the created workspace"
}

output "workspace" {
  value       = azurerm_databricks_workspace.this
  description = "Full workspace object"
}

output "ipgroup_cidrs" {
  description = "A map containing the CIDRs for the host and container IP groups, used for network segmentation in Azure."
  value = {
    ipgroup_host_cidr      = azurerm_ip_group_cidr.host.cidr
    ipgroup_container_cidr = azurerm_ip_group_cidr.container.cidr
  }
}

output "resource_group_name" {
  description = "Name of deployed resource group"
  value       = azurerm_resource_group.this.name

}
