locals {
  serverless_internet_allowed_domains = [for dest in var.public_repos : dest if !startswith(dest, "*.")]
  serverless_internet_allowed_destinations = [
    for dest in local.serverless_internet_allowed_domains :
    {
      destination               = trimprefix(dest, "*."),
      internet_destination_type = "DNS_NAME"
    }
  ]

  # We use this to make sure that if we provision the 10th NCC in a region, that it does not cause subsequent terraform
  # plans/applies to fail due to the precondition on the NCC resource.
  ncc_name          = "ncc-${var.location}-${var.hub_resource_suffix}"
  current_ncc_count = length([for k in data.databricks_mws_network_connectivity_configs.this.names : k if k != local.ncc_name])
  ncc_region_limit  = 10
}

# This NCC is shared across all workspaces created by SRA
resource "databricks_mws_network_connectivity_config" "this" {
  name   = local.ncc_name
  region = var.location

  lifecycle {
    precondition {
      condition     = local.current_ncc_count < local.ncc_region_limit
      error_message = "There are already ${local.ncc_region_limit} NCCs in ${var.location}!"
    }
  }
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
