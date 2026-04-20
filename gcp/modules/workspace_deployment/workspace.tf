resource "databricks_mws_private_access_settings" "pas" {
  count                        = (!var.use_existing_pas && (var.use_psc || var.use_frontend_psc)) ? 1 : 0
  provider                     = databricks.accounts
  private_access_settings_name = "${var.resource_prefix}-pas-${local.deployment_suffix}"
  region                       = var.google_region
  public_access_enabled        = true
  private_access_level         = "ACCOUNT"
}

resource "databricks_mws_workspaces" "this" {
  provider       = databricks.accounts
  account_id     = var.databricks_account_id
  workspace_name = var.workspace_name
  location       = var.google_region

  # Serverless workspaces set compute_mode explicitly and skip network config.
  compute_mode = var.serverless_workspace_deployment ? "SERVERLESS" : null

  # cloud_resource_container only applies to non-serverless workspaces.
  dynamic "cloud_resource_container" {
    for_each = var.serverless_workspace_deployment ? [] : [1]
    content {
      gcp {
        project_id = var.google_project
      }
    }
  }

  private_access_settings_id = (var.use_psc || var.use_frontend_psc) ? (
    var.use_existing_pas ? var.existing_pas_id : databricks_mws_private_access_settings.pas[0].private_access_settings_id
  ) : null

  network_id = var.serverless_workspace_deployment ? null : databricks_mws_networks.network_config[0].network_id

  # CMEK keys:
  # - storage CMEK: classic workspaces only (not applicable to serverless)
  # - managed-services CMEK: both serverless and classic
  storage_customer_managed_key_id = (var.use_cmek && !var.serverless_workspace_deployment) ? (
    var.use_existing_cmek ? var.cmek_resource_id : databricks_mws_customer_managed_keys.this[0].customer_managed_key_id
  ) : null
  managed_services_customer_managed_key_id = var.use_cmek ? (
    var.use_existing_cmek ? var.cmek_resource_id : databricks_mws_customer_managed_keys.this[0].customer_managed_key_id
  ) : null

  depends_on = [
    google_compute_firewall.db_subnet_ingress,
  ]
}

# Workspace-level hardening configuration.
resource "databricks_workspace_conf" "this" {
  count    = var.serverless_workspace_deployment ? 0 : 1
  provider = databricks.workspace

  custom_config = {
    "enableIpAccessLists"    = "true"
    "enableVerboseAuditLogs" = "true"
    "enableDbfsFileBrowser"  = "false"
    "maxTokenLifetimeDays"   = "90"
  }

  depends_on = [databricks_mws_workspaces.this]
}

# Account-level permission assignment APIs are not immediately available after
# workspace creation. This short sleep (chained after workspace_conf) gives the
# API time to become ready before admin assignments run.
resource "time_sleep" "wait_for_workspace_apis" {
  count           = var.serverless_workspace_deployment ? 0 : 1
  create_duration = "5s"
  depends_on      = [databricks_workspace_conf.this]
}
