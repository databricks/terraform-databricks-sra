# Data source to look up the existing VPC when use_existing_vpc = true.
# Used for DNS zone attachment and other references that need the network self_link.
data "google_compute_network" "existing" {
  count   = (var.use_existing_vpc && !var.serverless_workspace_deployment) ? 1 : 0
  name    = var.existing_vpc_name
  project = var.google_project
}

locals {
  # Network identifiers resolved to either the created or existing VPC.
  vpc_self_link = var.serverless_workspace_deployment ? "" : (
    var.use_existing_vpc
    ? data.google_compute_network.existing[0].self_link
    : google_compute_network.dbx_private_vpc[0].self_link
  )
}

resource "google_compute_network" "dbx_private_vpc" {
  count                   = (var.use_existing_vpc || var.serverless_workspace_deployment) ? 0 : 1
  project                 = var.google_project
  provider                = google
  name                    = "${var.resource_prefix}-vpc-${local.deployment_suffix}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "network-with-private-secondary-ip-ranges" {
  count                    = (var.use_existing_vpc || var.serverless_workspace_deployment) ? 0 : 1
  provider                 = google
  name                     = "${var.resource_prefix}-subnet-${local.deployment_suffix}"
  ip_cidr_range            = var.nodes_ip_cidr_range
  region                   = var.google_region
  network                  = google_compute_network.dbx_private_vpc[0].id
  private_ip_google_access = true
}

resource "google_compute_router" "router" {
  count   = (var.use_psc || var.use_existing_vpc || var.serverless_workspace_deployment) ? 0 : 1
  name    = "${var.resource_prefix}-router-${local.deployment_suffix}"
  region  = google_compute_subnetwork.network-with-private-secondary-ip-ranges[0].region
  network = google_compute_network.dbx_private_vpc[0].id
}

resource "google_compute_router_nat" "nat" {
  count                              = (var.use_psc || var.use_existing_vpc || var.serverless_workspace_deployment) ? 0 : 1
  name                               = "${var.resource_prefix}-nat-${local.deployment_suffix}"
  router                             = google_compute_router.router[0].name
  region                             = google_compute_router.router[0].region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "databricks_mws_networks" "network_config" {
  count = var.serverless_workspace_deployment ? 0 : 1

  provider   = databricks.accounts
  account_id = var.databricks_account_id
  # network_name has a 30-char limit. Drop the region from the name (it is
  # still set on the resource via subnet_region below) to keep room for longer
  # resource_prefix / deployment_suffix values.
  network_name = "${var.resource_prefix}-net-${local.deployment_suffix}"

  gcp_network_info {
    network_project_id = var.google_project
    vpc_id             = var.use_existing_vpc ? var.existing_vpc_name : google_compute_network.dbx_private_vpc[0].name
    subnet_id          = var.use_existing_vpc ? var.existing_subnet_name : google_compute_subnetwork.network-with-private-secondary-ip-ranges[0].name
    subnet_region      = var.google_region
  }

  depends_on = [
    google_compute_network.dbx_private_vpc,
    google_compute_subnetwork.network-with-private-secondary-ip-ranges,
    google_compute_router_nat.nat,
  ]

  dynamic "vpc_endpoints" {
    for_each = var.use_psc ? [1] : []
    content {
      dataplane_relay = var.use_existing_databricks_vpc_eps ? [var.existing_databricks_vpc_ep_relay] : [try(databricks_mws_vpc_endpoint.relay_vpce[0].vpc_endpoint_id, "")]
      rest_api        = var.use_existing_databricks_vpc_eps ? [var.existing_databricks_vpc_ep_workspace] : [try(databricks_mws_vpc_endpoint.backend_rest_vpce[0].vpc_endpoint_id, "")]
    }
  }
}
