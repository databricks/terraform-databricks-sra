databricks_account_id = "00000000-0000-0000-0000-000000000000"
hub_resource_suffix   = "srahub"
hub_vnet_cidr         = "10.0.0.0/22"
location              = "westus2"
resource_suffix       = "spoke"
tags = {
  Owner = "john.smith@company.com"
}
workspace_vnet = {
  cidr = "10.0.4.0/22"
}

# Network mode: create_workspace_vnet defaults to true for SRA-managed network
# create_workspace_vnet = true

# Optional: Disable customer-managed keys if needed (defaults to enabled)
# cmk_enabled = false

# Optional: Enhanced security compliance
# workspace_security_compliance = {
#   compliance_security_profile_enabled   = true
#   compliance_security_profile_standards = ["HIPAA"]
#   enhanced_security_monitoring_enabled  = true
#   automatic_cluster_update_enabled      = true
# }

subscription_id = "ffffffff-ffff-ffff-ffff-ffffffffffff"
