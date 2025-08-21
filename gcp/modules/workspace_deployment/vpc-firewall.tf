resource "google_compute_firewall" "deny_egress" {
  count = var.harden_network ? 1 : 0
  depends_on = [
    google_compute_network.dbx_private_vpc
  ]
  name                    = "deny-egress-${google_compute_network.dbx_private_vpc.name}"
  direction               = "EGRESS"
  priority                = 1100
  destination_ranges      = ["0.0.0.0/0"]
  source_ranges           = []
  # allow                   = []
  deny  {
    protocol              = "all"
  }
  network                 = google_compute_network.dbx_private_vpc.self_link
}

resource "google_compute_firewall" "from_gcp_healthcheck" {
  depends_on = [
    google_compute_network.dbx_private_vpc
  ]
  count = var.harden_network ? 1 : 0
  name                    = "from-gcp-healthcheck-${google_compute_network.dbx_private_vpc.name}"
  direction               = "INGRESS"
  priority                = 1010
  source_ranges           = ["130.211.0.0/22", "35.191.0.0/16"]
  destination_ranges      = []
  allow {
    protocol              = "tcp"
    ports                 = ["80", "443"]
  }
  network                 = google_compute_network.dbx_private_vpc.self_link
}

resource "google_compute_firewall" "to_gcp_healthcheck" {
  depends_on = [
    google_compute_network.dbx_private_vpc
  ]
  count = var.harden_network ? 1 : 0
  name                    = "to-gcp-healthcheck-${google_compute_network.dbx_private_vpc.name}"
  direction               = "EGRESS"
  priority                = 1000
  destination_ranges      = ["130.211.0.0/22", "35.191.0.0/16"]
  source_ranges           = []
  allow {
    protocol              = "tcp"
    ports                 = ["80", "443"]
  }
  network                 = google_compute_network.dbx_private_vpc.self_link
}


resource "google_compute_firewall" "egress_intra_subnet" {
  depends_on = [
    google_compute_network.dbx_private_vpc,google_compute_subnetwork.network-with-private-secondary-ip-ranges
  ]
  count                   = var.harden_network ? 1 : 0
  name                    = "databricks-egress-intra-subnet"
  direction               = "EGRESS"
  priority                = 1000
  destination_ranges      = [
    google_compute_subnetwork.network-with-private-secondary-ip-ranges.ip_cidr_range
  ]
  source_ranges           = []
  allow {
    protocol              = "all"
  }
  network                 = google_compute_network.dbx_private_vpc.self_link
}

resource "google_compute_firewall" "to_databricks_control_plane" {
  depends_on = [
    google_compute_network.dbx_private_vpc
  ]
  count = var.harden_network && !var.use_psc ? 1 : 0
  name                    = "to-databricks-control-plane-${google_compute_network.dbx_private_vpc.name}"
  direction               = "EGRESS"
  priority                = 1000
  destination_ranges      = [
    # ADD REGIONAL IPS as listed here : https://docs.databricks.com/gcp/en/resources/ip-domain-region
    # var.control_plane_ip_1,  # X.X.X.X/32
    # var.control_plane_ip_2,  # X.X.X.X/28
    # var.control_plane_ip_3,  # X.X.X.X/28
    # var.control_plane_ip_4   # Y.Y.Y.Y/32
  ]
  source_ranges           = []
  allow {
    protocol              = "tcp"
    ports                 = ["443", "8443-8451"]
  }
  network                 = google_compute_network.dbx_private_vpc.self_link
}

resource "google_compute_firewall" "to_google_apis" {
  depends_on = [
    google_compute_network.dbx_private_vpc
  ]
  count = var.harden_network ? 1 : 0
  name                    = "to-google-apis-${google_compute_network.dbx_private_vpc.name}"
  direction               = "EGRESS"
  priority                = 1010
  destination_ranges      = ["199.36.153.4/30"]
  source_ranges           = []
  allow {
    protocol              = "all"
  }
  network                 = google_compute_network.dbx_private_vpc.self_link
}
# This is a legacy rule that is not used anymore, but kept for reference, and useful if UC is not used
# resource "google_compute_firewall" "to_databricks_managed_hive" {
#   count = var.harden_network ? 1 : 0
#   name                    = "to-databricks-managed-hive-${google_compute_network.dbx_private_vpc.name}"
#   direction               = "EGRESS"
#   priority                = 1010
#   destination_ranges      = []
#   source_ranges           = [var.hive_metastore_ip]
#   allow {
#     protocol              = "tcp"
#     ports                 = ["3306"]
#   }
#   network                 = google_compute_network.dbx_private_vpc.self_link
# }
