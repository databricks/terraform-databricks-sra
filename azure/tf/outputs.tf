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
  description = "Information for the deployed spoke Databricks Workspace"
  value = {
    resource_group_name = module.spoke_workspace.resource_group_name
    workspace_url       = module.spoke_workspace.workspace_url
    workspace_id        = module.spoke_workspace.workspace_id
  }
}

output "spoke_workspace_catalog" {
  description = "Name of the catalog created for the spoke workspace"
  value       = module.spoke_catalog.catalog_name
}

output "spoke_workspace_network_cidr_blocks" {
  description = "CIDR blocks of the spoke workspace"
  value       = length(module.spoke_network) > 0 ? module.spoke_network[0].network_cidr_blocks : {}
}

output "spoke_firewall_rule_collection_group_id" {
  description = "ID of the spoke firewall rule collection group, if created"
  value       = length(azurerm_firewall_policy_rule_collection_group.spoke) > 0 ? azurerm_firewall_policy_rule_collection_group.spoke[0].id : null
}

output "spoke_network_policy_id" {
  description = "ID of the spoke network policy, if created"
  value       = length(databricks_account_network_policy.spoke) > 0 ? databricks_account_network_policy.spoke[0].network_policy_id : null
}
