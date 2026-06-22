locals {
  # Decompose the managed services key vault key URI (https://<vault>.vault.azure.net/keys/<name>/<version>)
  # into the parts that the ARM API expects in the encryption block.
  managed_services_key_parts = var.is_kms_enabled && var.managed_services_key_id != null ? regex(
    "^(?P<vault_uri>https://[^/]+/)keys/(?P<name>[^/]+)/(?P<version>[^/]+)$",
    var.managed_services_key_id
  ) : { vault_uri = null, name = null, version = null }

  csp_standards = var.enhanced_security_compliance.compliance_security_profile_standards
  csp_enabled   = var.enhanced_security_compliance.compliance_security_profile_enabled

  workspace_name = lookup(var.name_overrides, "databricks_workspace", module.naming.databricks_workspace.name)
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~>0.4"
  suffix  = [var.resource_suffix]
}

# Serverless-only Databricks workspace via the Microsoft.Databricks ARM API. computeMode = "Serverless"
# enforces this at the Azure resource level — classic cluster creation is rejected by the API. As a
# consequence, custom_parameters (subnets/VNET/NAT/public IP/managed disk CMK/etc.), managedResourceGroupId,
# defaultStorageFirewall, accessConnector, and requiredNsgRules are all forbidden and intentionally omitted.
resource "azapi_resource" "this" {
  type      = "Microsoft.Databricks/workspaces@2026-01-01"
  name      = local.workspace_name
  parent_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"
  location  = var.location
  tags      = var.tags

  body = {
    sku = {
      name = "premium"
    }
    properties = {
      computeMode = "Serverless"

      publicNetworkAccess = var.is_frontend_private_link_enabled ? "Disabled" : "Enabled"

      encryption = var.is_kms_enabled ? {
        entities = {
          managedServices = {
            keySource = "Microsoft.Keyvault"
            keyVaultProperties = {
              keyName     = local.managed_services_key_parts.name
              keyVaultUri = local.managed_services_key_parts.vault_uri
              keyVersion  = local.managed_services_key_parts.version
            }
          }
        }
      } : null

      enhancedSecurityCompliance = {
        automaticClusterUpdate = {
          value = var.enhanced_security_compliance.automatic_cluster_update_enabled == true ? "Enabled" : "Disabled"
        }
        complianceSecurityProfile = {
          value               = local.csp_enabled == true ? "Enabled" : "Disabled"
          complianceStandards = local.csp_standards == null ? [] : local.csp_standards
        }
        enhancedSecurityMonitoring = {
          value = var.enhanced_security_compliance.enhanced_security_monitoring_enabled == true ? "Enabled" : "Disabled"
        }
      }
    }
  }

  ignore_null_property   = true
  response_export_values = ["properties.workspaceUrl", "properties.workspaceId"]
}

data "azurerm_client_config" "current" {}

resource "time_sleep" "workspace_wait" {
  triggers = {
    workspace_id = azapi_resource.this.output.properties.workspaceId
  }
  create_duration  = "10s"
  destroy_duration = "10s"
}

# Grant Contributor on the workspace to the provisioner so downstream workspace-aliased providers
# (hub_catalog, SAT) can authenticate.
resource "azurerm_role_assignment" "contributor" {
  role_definition_name = "contributor"
  scope                = azapi_resource.this.id
  principal_id         = var.provisioner_principal_id
  description          = "This is granted by the Databricks SRA Terraform module. It grants workspace admin to the provisioner principal of the workspace."
}

# Gates the workspace_url output until role assignment + metastore assignment exist, so downstream
# provider aliases can rely on the URL being usable.
resource "null_resource" "admin_wait" {
  triggers = {
    workspace_url = azapi_resource.this.output.properties.workspaceUrl
    workspace_id  = azurerm_role_assignment.contributor.scope
    metastore_id  = databricks_metastore_assignment.this.metastore_id
  }
}

resource "databricks_metastore_assignment" "this" {
  workspace_id = azapi_resource.this.output.properties.workspaceId
  metastore_id = var.metastore_id
}

resource "databricks_mws_ncc_binding" "this" {
  network_connectivity_config_id = var.ncc_id
  workspace_id                   = azapi_resource.this.output.properties.workspaceId
}

resource "databricks_workspace_network_option" "this" {
  network_policy_id = var.network_policy_id
  workspace_id      = azapi_resource.this.output.properties.workspaceId
}

resource "databricks_disable_legacy_dbfs_setting" "this" {
  disable_legacy_dbfs {
    value = true
  }

  provider_config {
    workspace_id = azapi_resource.this.output.properties.workspaceId
  }
}

resource "databricks_disable_legacy_access_setting" "this" {
  disable_legacy_access {
    value = true
  }

  provider_config {
    workspace_id = azapi_resource.this.output.properties.workspaceId
  }
}
