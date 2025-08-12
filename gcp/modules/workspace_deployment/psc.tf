resource "google_compute_subnetwork" "backend_pe_subnetwork" {
  count = (var.use_existing_PSC_EP || !var.use_psc) ? 0 : 1
  name          = "var.google_pe_subnet-${random_string.suffix.result}"
  ip_cidr_range = var.google_pe_subnet_ip_cidr_range
  region        = var.google_region
  network       = google_compute_network.dbx_private_vpc.id

  private_ip_google_access = true

  depends_on=[google_compute_network.dbx_private_vpc]
}


resource "google_compute_forwarding_rule" "backend_psc_ep" {
  count = (var.use_existing_PSC_EP || !var.use_psc) ? 0 : 1
  depends_on = [
    google_compute_address.backend_pe_ip_address, google_compute_network.dbx_private_vpc
  ]
  region      = var.google_region
  project     = var.google_project
  name        = var.relay_pe
  network     = google_compute_network.dbx_private_vpc.id
  ip_address  = google_compute_address.backend_pe_ip_address[0].id
  target      = var.relay_service_attachment
  load_balancing_scheme = "" #This field must be set to "" if the target is an URI of a service attachment. Default value is EXTERNAL
}

resource "google_compute_address" "backend_pe_ip_address" {
  count = (var.use_existing_PSC_EP || !var.use_psc) ? 0 : 1
  name         = var.relay_pe_ip_name
  provider     = google
  project      = var.google_project
  region       = var.google_region
  subnetwork   = google_compute_subnetwork.backend_pe_subnetwork[0].name
  address_type = "INTERNAL"
}

resource "google_compute_forwarding_rule" "frontend_psc_ep" {
  count = (var.use_existing_PSC_EP || !var.use_psc) ? 0 : 1

  depends_on = [
    google_compute_address.frontend_pe_ip_address
  ]
  region      = var.google_region
  name        = var.workspace_pe
  project     = var.google_project
  network     = google_compute_network.dbx_private_vpc.id

  ip_address  = google_compute_address.frontend_pe_ip_address[0].id
  target      = var.workspace_service_attachment
  load_balancing_scheme = "" #This field must be set to "" if the target is an URI of a service attachment. Default value is EXTERNAL
}

resource "google_compute_address" "frontend_pe_ip_address" {
  count = (var.use_existing_PSC_EP || !var.use_psc) ? 0 : 1
  
  name         = var.workspace_pe_ip_name
  provider     = google
  project      = var.google_project
  region       = var.google_region
  subnetwork   = google_compute_subnetwork.backend_pe_subnetwork[0].name
  address_type = "INTERNAL"
}

resource "databricks_mws_vpc_endpoint" "backend_rest_vpce" {
  count = var.use_psc ? 1 : 0
  depends_on =[google_compute_forwarding_rule.backend_psc_ep]
  provider     = databricks.accounts
  account_id          = var.databricks_account_id
  vpc_endpoint_name   = "vpce-backend-rest"
  gcp_vpc_endpoint_info {
   project_id        = var.google_project
   psc_endpoint_name = var.workspace_pe
   endpoint_region   = google_compute_subnetwork.network-with-private-secondary-ip-ranges.region
 }
}

resource "databricks_mws_vpc_endpoint" "relay_vpce" {
  count = var.use_psc ? 1 : 0
  provider     = databricks.accounts
  depends_on = [ google_compute_forwarding_rule.frontend_psc_ep ]
  account_id          = var.databricks_account_id
  vpc_endpoint_name   = "vpce-relay"
  gcp_vpc_endpoint_info {
    project_id        = var.google_project
    psc_endpoint_name = var.relay_pe
    endpoint_region   = google_compute_subnetwork.network-with-private-secondary-ip-ranges.region
 }
}
output "front_end_psc_status" {
  value = var.use_psc ? (
    "Frontend psc status: ${var.use_existing_PSC_EP ? "Pre-provisioned" : google_compute_forwarding_rule.frontend_psc_ep[0].psc_connection_status}"
  ) : "PSC not in use"
}

output "backend_end_psc_status" {
  value = var.use_psc ? (
    "Backend psc status: ${var.use_existing_PSC_EP ? "Pre-provisioned" : google_compute_forwarding_rule.backend_psc_ep[0].psc_connection_status}"
  ) : "PSC not in use"
}
