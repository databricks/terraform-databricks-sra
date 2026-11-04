# Cloud-specific endpoints derived from var.azure_environment, which is the only setting a
# deployment needs in order to target Azure Commercial or Azure Government.
#
# These are not customer-configurable. Azure mandates the exact private DNS zone name for each
# resource type in each cloud — a private endpoint whose A record lands in a differently named zone
# is simply never resolved — and each cloud has exactly one Databricks account console. Adding a new
# cloud means extending both this map and the azure_environment validation in variables.tf.
locals {
  azure_cloud_endpoints = {
    public = {
      account_host       = "https://accounts.azuredatabricks.net"
      databricks_backend = "privatelink.azuredatabricks.net"
      storage            = "core.windows.net"
      key_vault          = "vaultcore.azure.net"
    }
    usgovernment = {
      account_host       = "https://accounts.usgov.databricks.azure.us"
      databricks_backend = "privatelink.usgov.databricks.azure.us"
      storage            = "core.usgovcloudapi.net"
      key_vault          = "vaultcore.usgovcloudapi.net"
    }
  }

  azure_cloud = local.azure_cloud_endpoints[var.azure_environment]

  databricks_account_host = local.azure_cloud.account_host

  private_dns_zone_names = {
    backend   = local.azure_cloud.databricks_backend
    dfs       = "privatelink.dfs.${local.azure_cloud.storage}"
    blob      = "privatelink.blob.${local.azure_cloud.storage}"
    key_vault = "privatelink.${local.azure_cloud.key_vault}"
  }
}

# Context-based ingress policy shared by every SRA-managed network policy. Only public access is governed: it is
# restricted to the allowed IP ranges for all users, service principals, and destinations. Private and
# cross-workspace access are left unset, so existing private connectivity behavior is unchanged. When dry_run is
# true the same policy is written to ingress_dry_run instead, which logs would-be denials without blocking.
locals {
  workspace_ingress_policy = var.workspace_ingress_control.enabled ? {
    public_access = {
      restriction_mode = "RESTRICTED_ACCESS"
      allow_rules = [
        {
          label = "sra-allowed-ip-ranges"
          origin = {
            included_ip_ranges = {
              ip_ranges = var.workspace_ingress_control.allowed_ip_ranges
            }
          }
          destination = {
            all_destinations = true
          }
        }
      ]
    }
    # Not managed by SRA. These are the defaults the API reports when only public_access is sent; they are set
    # explicitly because the provider does not treat them as computed and otherwise fails the apply with
    # "Provider produced inconsistent result after apply" (observed on databricks provider 1.140.0).
    private_access = {
      restriction_mode = "ALLOW_ALL_REGISTERED_ENDPOINTS"
    }
    cross_workspace_access = {
      restriction_mode = "LEGACY_MODE"
    }
  } : null

  network_policy_ingress         = var.workspace_ingress_control.dry_run ? null : local.workspace_ingress_policy
  network_policy_ingress_dry_run = var.workspace_ingress_control.dry_run ? local.workspace_ingress_policy : null
}

# Azure regions with a Databricks Private Link Service for performance-intensive services (Service Direct). Source:
# https://learn.microsoft.com/en-us/azure/databricks/resources/ip-domain-region#service-direct-resource-ids
locals {
  service_direct_regions = [
    "australiacentral", "australiaeast", "australiasoutheast", "brazilsouth", "canadacentral", "canadaeast",
    "centralindia", "centralus", "eastasia", "eastus", "eastus2", "francecentral", "germanywestcentral", "japaneast",
    "japanwest", "koreacentral", "mexicocentral", "northcentralus", "northeurope", "norwayeast", "qatarcentral",
    "southafricanorth", "southcentralus", "southeastasia", "southindia", "swedencentral", "switzerlandnorth",
    "uaenorth", "uksouth", "ukwest", "westcentralus", "westeurope", "westindia", "westus", "westus2", "westus3",
  ]
}
