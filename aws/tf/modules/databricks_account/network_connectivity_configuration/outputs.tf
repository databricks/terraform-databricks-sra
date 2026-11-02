output "ncc_id" {
  description = "Network Connectivity Configuration ID."
  value       = databricks_mws_network_connectivity_config.ncc.network_connectivity_config_id
}
output "private_network_gateway_name" {
  description = "Canonical resource name of the private network gateway. Null when the gateway is not enabled."
  value       = one(databricks_private_network_gateway.this[*].name)
}
