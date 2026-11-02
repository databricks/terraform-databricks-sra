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
  # encryption_enabled = true  # Auto-enabled when workspace_security_compliance.compliance_security_profile_enabled = true
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

# Optional: Context-based ingress control - restrict public workspace access to these IP ranges
# Start with dry_run = true and review system.access.inbound_network before enforcing
# workspace_ingress_control = {
#   enabled           = true
#   dry_run           = true
#   allowed_ip_ranges = ["203.0.113.0/24"]
# }

subscription_id = "ffffffff-ffff-ffff-ffff-ffffffffffff"

# Optional: Azure Government. See template_azure_gov.example.tfvars
# azure_environment = "usgovernment"
