# Terraform Documentation: https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_ncc_binding

# Network Connectivity Configuration - Binding
resource "databricks_mws_ncc_binding" "ncc_binding" {
  network_connectivity_config_id = var.ncc_id
  workspace_id                   = var.workspace_id
}