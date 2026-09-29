output "network_policy_id" {
  description = "Network Policy ID."
  value       = databricks_account_network_policy.restrictive_network_policy.network_policy_id
}