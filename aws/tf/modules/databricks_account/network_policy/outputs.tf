output "cross_workspace_access" {
  description = "Cross-workspace ingress settings applied to the network policy. Null in GovCloud, where the setting is not supported."
  value       = databricks_account_network_policy.restrictive_network_policy.ingress.cross_workspace_access
}

output "network_policy_id" {
  description = "Network Policy ID."
  value       = databricks_account_network_policy.restrictive_network_policy.network_policy_id
}