output "hub_network_subnets" {
  description = "Subnets created in the hub network"
  value       = var.create_hub ? module.subnet_addrs[0].network_cidr_blocks : null
}

output "hub_resource_group_name" {
  description = "Name of created hub resource group"
  value       = var.create_hub ? module.hub[0].resource_group_name : null
}

output "hub_workspace_info" {
  description = "URLs for the one (or more) deployed Databricks Workspaces"
  value       = var.create_hub ? [module.hub[0].resource_group_name, module.webauth_workspace[0].workspace_url] : null
}

output "spoke_workspace_info" {
  description = "URLs for the one (or more) deployed Databricks Workspaces"
  value       = [module.spoke_workspace.resource_group_name, module.spoke_workspace.workspace_url]
}

output "spoke_workspace_catalog" {
  description = "Name of the catalog created for the spoke workspace"
  value       = module.spoke_catalog.catalog_name
}
