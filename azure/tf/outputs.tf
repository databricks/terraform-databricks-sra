output "hub_network_subnets" {
  description = "Subnets created in the hub network"
  value       = module.subnet_addrs.network_cidr_blocks
}

output "hub_resource_group_name" {
  description = "Name of created hub resource group"
  value       = module.hub.resource_group_name
}

output "spoke_workspace_urls" {
  description = "URLs for the one (or more) deployed Databricks Workspaces"
  # value       = values(module.spoke)[*].workspace_url
  value = { for k, v in module.spoke : k => v.workspace_url }
}
