# NCC creation and network policies
data "databricks_mws_network_connectivity_configs" "this" {
  region = var.location
}

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
  network_policy_id = "np-${var.resource_suffix}-restrictive"
  account_id        = var.databricks_account_id
  egress = {
    network_access = {
      restriction_mode              = "RESTRICTED_ACCESS"
      allowed_internet_destinations = local.spoke_internet_allowed_destinations
      policy_enforcement = {
        enforcement_mode = "ENFORCED"
      }
    }
  }
}

resource "databricks_account_network_policy" "hub_policy" {
  network_policy_id = "np-${var.resource_suffix}-hub"
  account_id        = var.databricks_account_id
  egress = {
    network_access = {
      restriction_mode              = "RESTRICTED_ACCESS"
      allowed_internet_destinations = local.hub_internet_allowed_destinations
      policy_enforcement = {
        enforcement_mode = "ENFORCED"
      }
    }
  }
}
