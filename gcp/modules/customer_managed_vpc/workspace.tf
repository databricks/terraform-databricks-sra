resource "databricks_mws_private_access_settings" "pas" {
 account_id                   = var.databricks_account_id
 provider       = databricks.accounts
 private_access_settings_name = "pas-${random_string.suffix.result}"
 region                       = google_compute_subnetwork.network-with-private-secondary-ip-ranges.region
 public_access_enabled        = true
 private_access_level         = "ACCOUNT"
}

resource "databricks_mws_workspaces" "this" {
  provider       = databricks.accounts
  account_id     = var.databricks_account_id
  workspace_name = "tf-demo-test-${random_string.suffix.result}"
  location       = google_compute_subnetwork.network-with-private-secondary-ip-ranges.region
  cloud_resource_container {
    gcp {
      project_id = var.google_project
    }
  }

  private_access_settings_id = databricks_mws_private_access_settings.pas.private_access_settings_id
  network_id = databricks_mws_networks.this.network_id
  gke_config {
    connectivity_type = "PRIVATE_NODE_PUBLIC_MASTER"
    master_ip_range   = var.mws_workspace_gke_master_ip_range
  }

  token {
    comment = "Terraform generated PAT"
    // 30 day token
    lifetime_seconds = 2592000
  }

  # this makes sure that the NAT is created for outbound traffic before creating the workspace
  depends_on = [google_compute_router_nat.nat]
}

resource "databricks_workspace_conf" "this" {
  provider = databricks.workspace
  custom_config = {
    "maxTokenLifetimeDays" = "30"
  }
  depends_on = [ databricks_mws_workspaces.this ]
}

output "databricks_host" {
  value = databricks_mws_workspaces.this.workspace_url
}

output "databricks_token" {
  value     = databricks_mws_workspaces.this.token[0].token_value
  sensitive = true
}