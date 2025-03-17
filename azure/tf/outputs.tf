output "hub_network_subnets" {
  description = "Subnets created in the hub network"
  value       = module.subnet_addrs.network_cidr_blocks
}

output "hub_resource_group_name" {
  description = "Name of created hub resource group"
  value       = module.hub.resource_group_name
}

output "spoke_workspace_info" {
  description = "URLs for the one (or more) deployed Databricks Workspaces"
  value       = [module.spoke.resource_group_name, module.spoke.workspace_url, module.spoke.uc_abfss_url]
}
