resource "google_compute_network" "dbx_private_vpc" {
  project                 = var.google_project
  name                    = "databricks-workspace-vpc-${random_string.suffix.result}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "network-with-private-secondary-ip-ranges" {
  name          = "databricks-workspace-subnet-${random_string.suffix.result}"
  ip_cidr_range = var.nodes_ip_cidr_range
  region        = var.google_region
  network       = google_compute_network.dbx_private_vpc.id
  private_ip_google_access = true
}

resource "databricks_mws_networks" "network_config" {
  provider     = databricks.accounts
  account_id   = var.databricks_account_id
  network_name = "config-eu1-${random_string.suffix.result}"
  gcp_network_info {
    network_project_id    = var.google_project
    vpc_id                = var.use_existing_vpc? var.existing_vpc_name:google_compute_network.dbx_private_vpc.name
    subnet_id             = var.use_existing_vpc?var.existing_subnet_name:google_compute_subnetwork.network-with-private-secondary-ip-ranges.name
    subnet_region         = var.google_region
  }
  vpc_endpoints {
   dataplane_relay = [databricks_mws_vpc_endpoint.relay_vpce.vpc_endpoint_id]
   rest_api        = [databricks_mws_vpc_endpoint.backend_rest_vpce.vpc_endpoint_id]
  }
}