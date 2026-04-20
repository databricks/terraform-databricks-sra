resource "google_compute_subnetwork" "backend_pe_subnetwork" {
  count         = (var.use_existing_PSC_EP || var.use_existing_vpc || !var.use_psc || var.serverless_workspace_deployment) ? 0 : 1
  name          = "${var.resource_prefix}-pe-subnet-${local.deployment_suffix}"
  ip_cidr_range = var.google_pe_subnet_ip_cidr_range
  region        = var.google_region
  network       = google_compute_network.dbx_private_vpc[0].id

  private_ip_google_access = true

  depends_on = [google_compute_network.dbx_private_vpc]
}

resource "google_compute_forwarding_rule" "backend_psc_ep" {
  count = (var.use_existing_PSC_EP || var.use_existing_vpc || !var.use_psc || var.serverless_workspace_deployment) ? 0 : 1
  depends_on = [
    google_compute_address.backend_pe_ip_address,
    google_compute_network.dbx_private_vpc,
  ]
  region                = var.google_region
  project               = var.google_project
  name                  = var.relay_pe
  network               = google_compute_network.dbx_private_vpc[0].id
  ip_address            = google_compute_address.backend_pe_ip_address[0].id
  target                = var.relay_service_attachment
  load_balancing_scheme = "" # Must be "" when target is a service attachment URI.
}

resource "google_compute_address" "backend_pe_ip_address" {
  count        = (var.use_existing_PSC_EP || var.use_existing_vpc || !var.use_psc || var.serverless_workspace_deployment) ? 0 : 1
  name         = var.relay_pe_ip_name
  provider     = google
  project      = var.google_project
  region       = var.google_region
  subnetwork   = google_compute_subnetwork.backend_pe_subnetwork[0].name
  address_type = "INTERNAL"
}

resource "google_compute_forwarding_rule" "frontend_psc_ep" {
  count = (var.use_existing_PSC_EP || var.use_existing_vpc || !var.use_psc || var.serverless_workspace_deployment) ? 0 : 1

  depends_on = [
    google_compute_address.frontend_pe_ip_address,
  ]
  region                = var.google_region
  name                  = var.workspace_pe
  project               = var.google_project
  network               = google_compute_network.dbx_private_vpc[0].id
  ip_address            = google_compute_address.frontend_pe_ip_address[0].id
  target                = var.workspace_service_attachment
  load_balancing_scheme = "" # Must be "" when target is a service attachment URI.
}

resource "google_compute_address" "frontend_pe_ip_address" {
  count = (var.use_existing_PSC_EP || var.use_existing_vpc || !var.use_psc || var.serverless_workspace_deployment) ? 0 : 1

  name         = var.workspace_pe_ip_name
  provider     = google
  project      = var.google_project
  region       = var.google_region
  subnetwork   = google_compute_subnetwork.backend_pe_subnetwork[0].name
  address_type = "INTERNAL"
}

# Register the GCP PSC forwarding rules with the Databricks account.
# Created whenever use_psc = true and the caller does NOT want to reuse an
# existing Databricks-side registration — independent of whether the GCP PSC
# forwarding rules were created by this module or supplied via BYO-VPC.
resource "databricks_mws_vpc_endpoint" "backend_rest_vpce" {
  count = (var.use_psc && !var.use_existing_databricks_vpc_eps && !var.serverless_workspace_deployment) ? 1 : 0

  provider          = databricks.accounts
  account_id        = var.databricks_account_id
  vpc_endpoint_name = "vpce-backend-rest-${local.deployment_suffix}"

  gcp_vpc_endpoint_info {
    project_id        = var.google_project
    psc_endpoint_name = var.workspace_pe
    endpoint_region   = var.google_region
  }

  # No-op wait when the forwarding rule is BYO (count = 0 resource).
  depends_on = [google_compute_forwarding_rule.frontend_psc_ep]
}

resource "databricks_mws_vpc_endpoint" "relay_vpce" {
  count = (var.use_psc && !var.use_existing_databricks_vpc_eps && !var.serverless_workspace_deployment) ? 1 : 0

  provider          = databricks.accounts
  account_id        = var.databricks_account_id
  vpc_endpoint_name = "vpce-relay-${local.deployment_suffix}"

  gcp_vpc_endpoint_info {
    project_id        = var.google_project
    psc_endpoint_name = var.relay_pe
    endpoint_region   = var.google_region
  }

  depends_on = [google_compute_forwarding_rule.backend_psc_ep]
}

# =============================================================================
# DNS zone + records for the PSC workspace
#
# Three modes (driven by create_dns_zone and existing_dns_zone_name):
#   1. create_dns_zone = true            -> module creates zone + A-records
#   2. existing_dns_zone_name set        -> module creates A-records in that zone
#   3. both unset                        -> module creates nothing (user manages DNS)
#
# If both are set, create_dns_zone wins and existing_dns_zone_name is ignored.
# =============================================================================

locals {
  # Whether to manage DNS records. Must depend only on input variables so that
  # Terraform can evaluate count at plan time (no computed attributes).
  manage_dns_records = var.use_psc && !var.serverless_workspace_deployment && (var.create_dns_zone || var.existing_dns_zone_name != "")

  # Resolve the managed zone name — used in the record resources' managed_zone
  # argument (evaluated at apply time, not in count).
  dns_managed_zone_name = var.create_dns_zone ? (
    length(google_dns_managed_zone.databricks_private_zone) > 0 ? google_dns_managed_zone.databricks_private_zone[0].name : ""
  ) : var.existing_dns_zone_name

  # Choose which IP to use in the DNS A-records.
  workspace_psc_ip = var.use_existing_PSC_EP ? var.existing_workspace_psc_endpoint_ip : (
    length(google_compute_address.frontend_pe_ip_address) > 0 ? google_compute_address.frontend_pe_ip_address[0].address : ""
  )

  # Relay (SCC tunnel) PSC IP — used for the tunnel.<region> A-record.
  relay_psc_ip = var.use_existing_PSC_EP ? var.existing_relay_psc_endpoint_ip : (
    length(google_compute_address.backend_pe_ip_address) > 0 ? google_compute_address.backend_pe_ip_address[0].address : ""
  )
}

# Mode 1: create a private DNS zone for gcp.databricks.com attached to this workspace's VPC.
resource "google_dns_managed_zone" "databricks_private_zone" {
  count = (var.use_psc && var.create_dns_zone && !var.serverless_workspace_deployment) ? 1 : 0

  name        = var.dns_zone_name
  project     = var.google_project
  dns_name    = "gcp.databricks.com."
  description = "Private DNS zone for Databricks PSC workspace"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.vpc_self_link
    }
  }
}

# A-record for the workspace URL.
resource "google_dns_record_set" "workspace_dns" {
  count = local.manage_dns_records ? 1 : 0

  depends_on = [databricks_mws_workspaces.this]

  project      = var.google_project
  name         = "${databricks_mws_workspaces.this.workspace_id}.${substr(databricks_mws_workspaces.this.workspace_id, -1, 1)}.gcp.databricks.com."
  type         = "A"
  ttl          = 300
  managed_zone = local.dns_managed_zone_name
  rrdatas      = [local.workspace_psc_ip]
}

# A-record for the dp- prefixed workspace URL.
resource "google_dns_record_set" "dp_workspace_dns" {
  count = local.manage_dns_records ? 1 : 0

  depends_on = [databricks_mws_workspaces.this]

  project      = var.google_project
  name         = "dp-${databricks_mws_workspaces.this.workspace_id}.${substr(databricks_mws_workspaces.this.workspace_id, -1, 1)}.gcp.databricks.com."
  type         = "A"
  ttl          = 300
  managed_zone = local.dns_managed_zone_name
  rrdatas      = [local.workspace_psc_ip]
}

# A-record for the SCC relay tunnel endpoint. Cluster VMs use this to
# establish the secure tunnel back to the Databricks control plane.
resource "google_dns_record_set" "tunnel_dns" {
  count = local.manage_dns_records ? 1 : 0

  project      = var.google_project
  name         = "tunnel.${var.google_region}.gcp.databricks.com."
  type         = "A"
  ttl          = 300
  managed_zone = local.dns_managed_zone_name
  rrdatas      = [local.relay_psc_ip]
}
