
module "firewall_rules" {
  source       = "terraform-google-modules/network/google//modules/firewall-rules"
  project_id   = var.google_project
  network_name = google_compute_network.dbx_private_vpc.name

  rules = [
  {
    name                    = "deny-egress-${google_compute_network.dbx_private_vpc.name}"
    direction               = "EGRESS"
    priority                = 1100
    destination_ranges      = ["0.0.0.0/0"]
    source_ranges           = []
    allow = []
    deny = [{protocol="all"}]
   
  },
  {    
    name                    = "to-databricks-managed-hive-${google_compute_network.dbx_private_vpc.name}"
    direction               = "EGRESS"
    priority                = 1010
    source_ranges           = [var.regional_metastore_ip]
    allow = [{
      protocol="tcp"
      ports = ["3306"]
    }]
  },
    {    
    name                    = "to-gke-health-checks-${google_compute_network.dbx_private_vpc.name}"
    direction               = "EGRESS"
    priority                = 1010
    destination_ranges = ["35.191.0.0/16","130.211.0.0/22"]
    allow = [{
      protocol="tcp"
      ports = ["443","80"]
    }]
  },
  {    
    name                    = "from-gke-health-checks-${google_compute_network.dbx_private_vpc.name}"
    direction               = "INGRESS"
    priority                = 1010
    destination_ranges = ["35.191.0.0/16","130.211.0.0/22"]
    allow = [{
      protocol="tcp"
      ports = ["443","80"]
    }]
  },
  {    
    name                    = "to-gke-cp-${google_compute_network.dbx_private_vpc.name}"
    direction               = "EGRESS"
    priority                = 1010
    destination_ranges = ["10.32.0.0/28"]
    allow = [{
      protocol="tcp"
      ports = ["443","10250"]
    }]
  },
  {    
    name                    = "to-google-apis-${google_compute_network.dbx_private_vpc.name}"
    direction               = "EGRESS"
    priority                = 1010
    destination_ranges = ["199.36.153.4/30"]
    allow = [{
      protocol="all"
    }]
  },
  {    
    name                    = "to-gke-nodes-subnet-${google_compute_network.dbx_private_vpc.name}"
    direction               = "EGRESS"
    priority                = 1010
    destination_ranges = [var.subnet_ip_cidr_range,var.pod_ip_cidr_range,var.service_ip_cidr_range]
    allow = [{
      protocol="all"
    }]
  }

  ]
}