

resource "databricks_mws_private_access_settings" "pas" {
 count = var.use_existing_pas ? 0 : 1
 provider       = databricks.accounts
 private_access_settings_name = "pas-${random_string.suffix.result}"
 region                       = google_compute_subnetwork.network-with-private-secondary-ip-ranges.region
 public_access_enabled        = true
 private_access_level         = "ACCOUNT"
}

resource "databricks_mws_workspaces" "this" {
  provider       = databricks.accounts
  account_id     = var.databricks_account_id
  workspace_name = var.workspace_name
  location       = google_compute_subnetwork.network-with-private-secondary-ip-ranges.region
  cloud_resource_container {
    gcp {
      project_id = var.google_project
    }
  }

  private_access_settings_id = var.use_existing_pas? var.existing_pas_id:databricks_mws_private_access_settings.pas[0].private_access_settings_id
  network_id = databricks_mws_networks.network_config.network_id
  gke_config {
    connectivity_type = "PRIVATE_NODE_PUBLIC_MASTER"
    master_ip_range   = var.mws_workspace_gke_master_ip_range
  }

  token {
    comment = "Terraform generated PAT"
    // 30 day token
    lifetime_seconds = 259200
  }
  storage_customer_managed_key_id = databricks_mws_customer_managed_keys.this.customer_managed_key_id
  managed_services_customer_managed_key_id = databricks_mws_customer_managed_keys.this.customer_managed_key_id

  # this makes sure that the NAT is created for outbound traffic before creating the workspace
  # not needed if the workspace uses backend PSC (recommended)
  # depends_on = [google_compute_router_nat.nat]
  depends_on = [ databricks_mws_customer_managed_keys.this]
}

resource "databricks_workspace_conf" "this" {
  provider = databricks.workspace
  custom_config = {
    "maxTokenLifetimeDays" = "30",
    "enableIpAccessLists" = true
  }
  depends_on = [ databricks_mws_workspaces.this ]
}

resource "databricks_ip_access_list" "allowed-list" {
  provider = databricks.workspace
  label     = "allow_in"
  list_type = "ALLOW"
  ip_addresses = var.ip_addresses
  
  depends_on = [databricks_workspace_conf.this]
}

output "databricks_host" {
  value = databricks_mws_workspaces.this.workspace_url
}

output "databricks_token" {
  value     = databricks_mws_workspaces.this.token[0].token_value
  sensitive = true
}