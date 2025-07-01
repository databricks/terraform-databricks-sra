# This NCC is shared across all workspaces created by SRA
resource "databricks_mws_network_connectivity_config" "this" {
  name   = "ncc-${var.location}-${var.hub_resource_suffix}"
  region = var.location
}

