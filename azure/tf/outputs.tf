output "hub_network_subnets" {
  value = module.subnet_addrs.network_cidr_blocks
}

<<<<<<< Updated upstream
# output "ipgroup_cidrs" {
#   value = module.spoke[*].ipgroup_cidrs
# }
=======
output "hub_resource_group_name" {
  description = "Name of created hub resource group"
  value       = module.hub.resource_group_name
}

output "spoke_workspace_info" {
  description = "URLs for the one (or more) deployed Databricks Workspaces"
  value       = [module.spoke.resource_group_name, module.spoke.workspace_url]
}
>>>>>>> Stashed changes
