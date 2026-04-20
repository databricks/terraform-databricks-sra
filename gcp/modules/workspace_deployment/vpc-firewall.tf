# Data source for existing subnetwork, used when use_existing_vpc = true.
data "google_compute_subnetwork" "existing" {
  count   = (var.use_existing_vpc && !var.serverless_workspace_deployment) ? 1 : 0
  name    = var.existing_subnet_name
  region  = var.google_region
  project = var.google_project
}

locals {
  subnet_name = var.use_existing_vpc ? var.existing_subnet_name : try(google_compute_subnetwork.network-with-private-secondary-ip-ranges[0].name, "")
  subnet_cidr = var.use_existing_vpc ? try(data.google_compute_subnetwork.existing[0].ip_cidr_range, "") : try(google_compute_subnetwork.network-with-private-secondary-ip-ranges[0].ip_cidr_range, "")
}

# Pre-create the intra-subnet ingress rule that Databricks would otherwise
# auto-create on the workspace's VPC. By managing it here, Terraform owns
# the rule's lifecycle end-to-end (no post-destroy cleanup needed).
#
# Skipped when use_existing_vpc = true — in bring-your-own-VPC mode the
# caller is responsible for all GCP-side networking, including the subnet
# ingress rule Databricks requires. Also skipped for serverless workspaces.
resource "google_compute_firewall" "db_subnet_ingress" {
  count = (var.use_existing_vpc || var.serverless_workspace_deployment) ? 0 : 1

  name      = "db-${local.subnet_name}-ingress"
  network   = google_compute_network.dbx_private_vpc[0].self_link
  direction = "INGRESS"
  priority  = 1000

  source_ranges = [local.subnet_cidr]

  allow {
    protocol = "all"
  }

  depends_on = [
    google_compute_network.dbx_private_vpc,
    google_compute_subnetwork.network-with-private-secondary-ip-ranges,
  ]
}

resource "google_compute_firewall" "deny_egress" {
  count = (var.harden_network && !var.serverless_workspace_deployment) ? 1 : 0
  depends_on = [
    google_compute_network.dbx_private_vpc,
  ]
  name               = "deny-egress-${local.subnet_name}"
  direction          = "EGRESS"
  priority           = 1100
  destination_ranges = ["0.0.0.0/0"]
  source_ranges      = []
  deny {
    protocol = "all"
  }
  network = local.vpc_self_link
}

resource "google_compute_firewall" "from_gcp_healthcheck" {
  count = (var.harden_network && !var.serverless_workspace_deployment) ? 1 : 0
  depends_on = [
    google_compute_network.dbx_private_vpc,
  ]
  name               = "from-gcp-healthcheck-${local.subnet_name}"
  direction          = "INGRESS"
  priority           = 1010
  source_ranges      = ["130.211.0.0/22", "35.191.0.0/16"]
  destination_ranges = []
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  network = local.vpc_self_link
}

resource "google_compute_firewall" "to_gcp_healthcheck" {
  count = (var.harden_network && !var.serverless_workspace_deployment) ? 1 : 0
  depends_on = [
    google_compute_network.dbx_private_vpc,
  ]
  name               = "to-gcp-healthcheck-${local.subnet_name}"
  direction          = "EGRESS"
  priority           = 1000
  destination_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  source_ranges      = []
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  network = local.vpc_self_link
}

resource "google_compute_firewall" "to_gcp_psc" {
  count = (var.harden_network && var.use_psc && !var.serverless_workspace_deployment) ? 1 : 0
  depends_on = [
    google_compute_network.dbx_private_vpc,
  ]
  name               = "to-psc-ep-${local.subnet_name}"
  direction          = "EGRESS"
  priority           = 1000
  destination_ranges = ["${google_compute_address.backend_pe_ip_address[0].address}/32", "${google_compute_address.frontend_pe_ip_address[0].address}/32"]
  source_ranges      = []
  allow {
    protocol = "tcp"
    ports    = ["443", "8443-8463"]
  }
  network = local.vpc_self_link
}

resource "google_compute_firewall" "egress_intra_subnet" {
  count = (var.harden_network && !var.serverless_workspace_deployment) ? 1 : 0
  depends_on = [
    google_compute_network.dbx_private_vpc,
    google_compute_subnetwork.network-with-private-secondary-ip-ranges,
  ]
  name               = "databricks-egress-intra-subnet-${local.deployment_suffix}"
  direction          = "EGRESS"
  priority           = 1000
  destination_ranges = [local.subnet_cidr]
  source_ranges      = []
  allow {
    protocol = "all"
  }
  network = local.vpc_self_link
}

resource "google_compute_firewall" "to_databricks_control_plane" {
  count = (var.harden_network && !var.use_psc && !var.serverless_workspace_deployment) ? 1 : 0
  depends_on = [
    google_compute_network.dbx_private_vpc,
  ]
  name      = "to-databricks-control-plane-${local.subnet_name}"
  direction = "EGRESS"
  priority  = 1000
  destination_ranges = [
    # ADD REGIONAL IPS as listed here: https://docs.databricks.com/gcp/en/resources/ip-domain-region
  ]
  source_ranges = []
  allow {
    protocol = "tcp"
    ports    = ["443", "8443-8451"]
  }
  network = local.vpc_self_link
}

resource "google_compute_firewall" "to_google_apis" {
  count = (var.harden_network && !var.serverless_workspace_deployment) ? 1 : 0
  depends_on = [
    google_compute_network.dbx_private_vpc,
  ]
  name               = "to-google-apis-${local.subnet_name}"
  direction          = "EGRESS"
  priority           = 1010
  destination_ranges = ["199.36.153.4/30"]
  source_ranges      = []
  allow {
    protocol = "all"
  }
  network = local.vpc_self_link
}
