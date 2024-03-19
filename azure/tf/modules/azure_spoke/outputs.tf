# The value of the "workspace_url" property represents the URL of the Databricks workspace
output "workspace_url" {
  value = azurerm_databricks_workspace.this.workspace_url
}

output "ipgroup_cidrs" {
  value = {
    ipgroup_host_cidr      = azurerm_ip_group_cidr.host.cidr
    ipgroup_container_cidr = azurerm_ip_group_cidr.container.cidr
  }
}
