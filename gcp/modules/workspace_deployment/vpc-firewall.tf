resource "google_compute_firewall" "deny_egress" {
  count = var.harden_network ? 1 : 0
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


# This is the only Egress rule that goes to a public internet IP
# It can be avoided if the workspace is UC-enabled and that the spark config is configured to avoid fetching the metastore IP
resource "google_compute_firewall" "to_databricks_managed_hive" {
  count = var.harden_network ? 1 : 0
  name                    = "to-databricks-managed-hive-${google_compute_network.dbx_private_vpc.name}"
  direction               = "EGRESS"
  priority                = 1010
  destination_ranges      = []
  source_ranges           = [var.hive_metastore_ip]
  allow {
    protocol              = "tcp"
    ports                 = ["3306"]
  }
  network                 = google_compute_network.dbx_private_vpc.self_link
}

resource "google_compute_firewall" "to_gke_health_checks" {
  count = var.harden_network ? 1 : 0
  name                    = "to-gke-health-checks-${google_compute_network.dbx_private_vpc.name}"
  direction               = "EGRESS"
  priority                = 1010
  destination_ranges      = ["35.191.0.0/16", "130.211.0.0/22"]
  source_ranges           = []
  allow {
    protocol              = "tcp"
    ports                 = ["443", "80"]
  }
  network                 = google_compute_network.dbx_private_vpc.self_link
}

resource "google_compute_firewall" "from_gke_health_checks" {
  count = var.harden_network ? 1 : 0
  name                    = "from-gke-health-checks-${google_compute_network.dbx_private_vpc.name}"
  direction               = "INGRESS"
  priority                = 1010
  destination_ranges      = []
  source_ranges           = ["35.191.0.0/16", "130.211.0.0/22"]
  allow {
    protocol              = "tcp"
    ports                 = ["443", "80"]
  }
  network                 = google_compute_network.dbx_private_vpc.self_link
}

resource "google_compute_firewall" "to_gke_cp" {
  count = var.harden_network ? 1 : 0
  name                    = "to-gke-cp-${google_compute_network.dbx_private_vpc.name}"
  direction               = "EGRESS"
  priority                = 1010
  destination_ranges      = ["10.32.0.0/28"]
  source_ranges           = []
  allow {
    protocol              = "tcp"
    ports                 = ["443", "10250"]
  }
  network                 = google_compute_network.dbx_private_vpc.self_link
}

resource "google_compute_firewall" "to_google_apis" {
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

resource "google_compute_firewall" "to_gke_nodes_subnet" {
  count = var.harden_network ? 1 : 0
  name                    = "to-gke-nodes-subnet-${google_compute_network.dbx_private_vpc.name}"
  direction               = "EGRESS"
  priority                = 1010
  destination_ranges      = [var.nodes_ip_cidr_range, var.pod_ip_cidr_range, var.service_ip_cidr_range]
  source_ranges           = []
  allow {
    protocol              = "all"
  }
  network                 = google_compute_network.dbx_private_vpc.self_link
}