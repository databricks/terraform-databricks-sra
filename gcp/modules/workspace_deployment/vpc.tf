resource "google_compute_network" "dbx_private_vpc" {
  count = var.use_existing_vpc ? 0 : 1
  project                 = var.google_project
  provider                = google
  name                    = "databricks-workspace-vpc-${random_string.suffix.result}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "network-with-private-secondary-ip-ranges" {
  count = var.use_existing_vpc ? 0 : 1
  provider      = google
  name          = "databricks-workspace-subnet-${random_string.suffix.result}"
  ip_cidr_range = var.nodes_ip_cidr_range
  region        = var.google_region
  network       = google_compute_network.dbx_private_vpc[0].id
  private_ip_google_access = true
}



resource "google_compute_router" "router" {
  count = var.use_psc ? 0 : 1
  name    = "my-router-${random_string.suffix.result}"
  region  = google_compute_subnetwork.network-with-private-secondary-ip-ranges[0].region
  network = google_compute_network.dbx_private_vpc[0].id
}

resource "google_compute_router_nat" "nat" {
  count = var.use_psc ? 0 : 1
  name                               = "my-router-nat-${random_string.suffix.result}"
  router                             = google_compute_router.router[0].name
  region                             = google_compute_router.router[0].region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}


resource "databricks_mws_networks" "network_config" {
  
  provider     = databricks.accounts
  account_id   = var.databricks_account_id
  network_name = "config-${var.google_region}-${random_string.suffix.result}"
  gcp_network_info {
    network_project_id    = var.google_project
    vpc_id                = var.use_existing_vpc ? var.existing_vpc_name : google_compute_network.dbx_private_vpc[0].name
    subnet_id             = var.use_existing_vpc ? var.existing_subnet_name : google_compute_subnetwork.network-with-private-secondary-ip-ranges[0].name
    subnet_region         = var.google_region
  }

  depends_on = [
    google_compute_network.dbx_private_vpc,
    google_compute_subnetwork.network-with-private-secondary-ip-ranges,
    google_compute_router_nat.nat
  ]
  
  dynamic "vpc_endpoints" {
    for_each = var.use_psc ? [1] : []
    content {
      dataplane_relay = var.use_existing_databricks_vpc_eps ? [var.existing_databricks_vpc_ep_relay] : [databricks_mws_vpc_endpoint.relay_vpce[0].vpc_endpoint_id]
      rest_api        = var.use_existing_databricks_vpc_eps ? [var.existing_databricks_vpc_ep_workspace] : [databricks_mws_vpc_endpoint.backend_rest_vpce[0].vpc_endpoint_id]
    }
  }
}
