locals {
  serverless_internet_allowed_domains = [for dest in var.public_repos : dest if !startswith(dest, "*.")]
  serverless_internet_allowed_destinations = [for dest in local.serverless_internet_allowed_domains : {
    destination               = trimprefix(dest, "*."),
    internet_destination_type = "DNS_NAME"
  }]
}

# This NCC is shared across all workspaces created by SRA
resource "databricks_mws_network_connectivity_config" "this" {
  name   = "ncc-${var.location}-${var.hub_resource_suffix}"
  region = var.location
}

resource "databricks_account_network_policy" "restrictive_network_policy" {
  account_id        = var.databricks_account_id
  network_policy_id = "np-${var.hub_resource_suffix}-restrictive"

  egress = {
    network_access = {
      restriction_mode              = "RESTRICTED_ACCESS"
      allowed_internet_destinations = local.serverless_internet_allowed_destinations
      policy_enforcement = {
        enforcement_mode = "ENFORCED"
      }
    }
  }
}
