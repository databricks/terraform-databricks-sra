output "hub_network_subnets" {
  description = "Subnets created in the hub network"
  value       = var.create_hub ? module.hub[0].network_cidr_blocks : null
}

output "hub_resource_group_name" {
  description = "Name of created hub resource group"
  value       = var.create_hub ? azurerm_resource_group.hub[0].name : null
}

output "hub_workspace_info" {
  description = "URLs for the one (or more) deployed Databricks Workspaces"
  value       = var.create_hub ? [azurerm_resource_group.hub[0].name, module.webauth_workspace[0].workspace_url] : null
}

output "spoke_workspace_info" {
  description = "URLs for the one (or more) deployed Databricks Workspaces"
  value       = [module.spoke_workspace["spoke"].resource_group_name, module.spoke_workspace["spoke"].workspace_url]
}

output "spoke_workspace_catalog" {
  description = "Name of the catalog created for the spoke workspace"
  value       = module.spoke_catalog.catalog_name
}
