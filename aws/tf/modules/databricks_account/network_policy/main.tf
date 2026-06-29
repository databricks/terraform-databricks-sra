# Terraform Documentation: https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/account_network_policy
# Terraform Documentation: https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/workspace_network_option

# NOTE: If this resource fails, verify that network_policy_id is no more than 32 characters.
# If using the Security Analysis Tool, please allow list PyPI.org to ensure functionality.

resource "databricks_account_network_policy" "restrictive_network_policy" {
  account_id        = var.databricks_account_id
  network_policy_id = "${var.resource_prefix}-np" # Must not be more than 32 characters.

  egress = {
    network_access = {
      restriction_mode = "RESTRICTED_ACCESS"
      policy_enforcement = {
        enforcement_mode = "ENFORCED"
      }
      # When the Security Analysis Tool is enabled, allow list PyPI so SAT can install its dependencies.
      allowed_internet_destinations = var.enable_security_analysis_tool ? [
        {
          destination               = "pypi.org"
          internet_destination_type = "DNS_NAME"
        },
        {
          destination               = "files.pythonhosted.org"
          internet_destination_type = "DNS_NAME"
        },
        {
          destination               = "release-assets.githubusercontent.com"
          internet_destination_type = "DNS_NAME"
        },
        {
          destination               = "github.com"
          internet_destination_type = "DNS_NAME"
        },
        {
          destination               = "raw.githubusercontent.com"
          internet_destination_type = "DNS_NAME"
        }
      ] : []
    }
  }

  # Optional IP-based ingress restriction. When context_based_ingress_ip_acl is non-empty, public access
  # to the workspace is restricted to the listed IPs/CIDRs; otherwise public access is left unrestricted.
  # NOTE: Verify that all IPs are correct before enabling this feature to prevent a lockout scenario.
  ingress = {
    public_access = {
      restriction_mode = length(var.context_based_ingress_ip_acl) > 0 ? "RESTRICTED_ACCESS" : "FULL_ACCESS"
      allow_rules = length(var.context_based_ingress_ip_acl) > 0 ? [
        {
          label = "${var.resource_prefix}-ingress-allow"
          origin = {
            included_ip_ranges = {
              ip_ranges = var.context_based_ingress_ip_acl
            }
          }
        }
      ] : []
    }
  }
}