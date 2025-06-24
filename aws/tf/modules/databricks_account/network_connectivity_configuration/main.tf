# Terraform Documentation: https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_network_connectivity_config

# Network Connectivity Configuration - Create
resource "databricks_mws_network_connectivity_config" "ncc" {
  name   = "${var.resource_prefix}-ncc"
  region = var.region
}