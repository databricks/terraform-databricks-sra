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
