resource "google_compute_network" "dbx_private_vpc" {
  count = var.use_existing_vpc ? 0 : 1
  project                 = var.google_project
  name                    = "tf-network-${random_string.suffix.result}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "network-with-private-secondary-ip-ranges" {
  count = var.use_existing_vpc ? 0 : 1
  name          = "ws-subnet-dbx-${random_string.suffix.result}"
  ip_cidr_range = var.nodes_ip_cidr_range
  region        = var.google_region
  network       = google_compute_network.dbx_private_vpc[0].id
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.pod_ip_cidr_range
  }
  secondary_ip_range {
    range_name    = "svc"
    ip_cidr_range = var.service_ip_cidr_range
  }
  private_ip_google_access = true
}

resource "databricks_mws_networks" "network_config" {
  provider     = databricks.accounts
  account_id   = var.databricks_account_id
  network_name = "config-eu1-${random_string.suffix.result}"
  gcp_network_info {
    network_project_id    = var.google_project
    vpc_id                = var.use_existing_vpc? var.existing_vpc_name:google_compute_network.dbx_private_vpc[0].name
    subnet_id             = var.use_existing_vpc?var.existing_subnet_name:google_compute_subnetwork.network-with-private-secondary-ip-ranges[0].name
    subnet_region         = var.google_region
    pod_ip_range_name     = var.use_existing_vpc?var.existing_pod_range_name:"pods"
    service_ip_range_name = var.use_existing_vpc?var.existing_service_range_name:"svc"
  }
  vpc_endpoints {
    
   dataplane_relay = [databricks_mws_vpc_endpoint.relay_vpce.vpc_endpoint_id]
   rest_api        = [databricks_mws_vpc_endpoint.backend_rest_vpce.vpc_endpoint_id]
  }

}