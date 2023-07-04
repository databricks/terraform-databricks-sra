resource "google_compute_network" "dbx_private_vpc" {
  project                 = var.google_project
  name                    = "tf-network-${random_string.suffix.result}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "network-with-private-secondary-ip-ranges" {
  name          = "test-dbx-${random_string.suffix.result}"
  ip_cidr_range = var.network_ip_cidr_range
  region        = var.google_region
  network       = google_compute_network.dbx_private_vpc.id
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.network_secondary_ip_cidr_range1
  }
  secondary_ip_range {
    range_name    = "svc"
    ip_cidr_range = var.network_secondary_ip_cidr_range2
  }
  private_ip_google_access = true
}

resource "google_compute_router" "router" {
  name    = "my-router-${random_string.suffix.result}"
  region  = google_compute_subnetwork.network-with-private-secondary-ip-ranges.region
  network = google_compute_network.dbx_private_vpc.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "my-router-nat-${random_string.suffix.result}"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "databricks_mws_vpc_endpoint" "backend_rest_vpce" {
depends_on =[google_compute_forwarding_rule.google_compute_forwarding_rule.backend_psc_ep]
 provider     = databricks.accounts

 account_id          = var.databricks_account_id
 vpc_endpoint_name   = "vpce-backend-rest-${random_string.suffix.result}"
 gcp_vpc_endpoint_info {
   project_id        = var.google_project
   psc_endpoint_name = var.workspace_pe
   endpoint_region   = google_compute_subnetwork.network-with-private-secondary-ip-ranges.region
 }
}

resource "databricks_mws_vpc_endpoint" "relay_vpce" {
  depends_on = [ google_compute_forwarding_rule.google_compute_forwarding_rule.frontend_psc_ep ]
 provider     = databricks.accounts

 account_id          = var.databricks_account_id
 vpc_endpoint_name   = "vpce-relay-${random_string.suffix.result}"
 gcp_vpc_endpoint_info {
   project_id        = var.google_project
   psc_endpoint_name = var.relay_pe
   endpoint_region   = google_compute_subnetwork.network-with-private-secondary-ip-ranges.region
 }
}


resource "databricks_mws_networks" "this" {
  provider     = databricks.accounts
  account_id   = var.databricks_account_id
  network_name = "test-demo-${random_string.suffix.result}"
  gcp_network_info {
    network_project_id    = var.google_project
    vpc_id                = google_compute_network.dbx_private_vpc.name
    subnet_id             = google_compute_subnetwork.network-with-private-secondary-ip-ranges.name
    subnet_region         = google_compute_subnetwork.network-with-private-secondary-ip-ranges.region
    pod_ip_range_name     = "pods"
    service_ip_range_name = "svc"
  }
  vpc_endpoints {
    
   dataplane_relay = [databricks_mws_vpc_endpoint.relay_vpce.vpc_endpoint_id]
   rest_api        = [databricks_mws_vpc_endpoint.backend_rest_vpce.vpc_endpoint_id]
  }

}