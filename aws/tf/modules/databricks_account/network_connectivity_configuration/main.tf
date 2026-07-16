# Terraform Documentation: https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_network_connectivity_config

# Network Connectivity Configuration - Create
resource "databricks_mws_network_connectivity_config" "ncc" {
  name   = "${var.resource_prefix}-ncc"
  region = var.region
}

# Terraform Documentation: https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_ncc_private_endpoint_rule

# Private Endpoint Rules - Create (none by default)
# NOTE: Rules targeting your own VPC endpoint service stay PENDING until the connection is accepted on the endpoint service side.
#
# The for_each key must be known at plan time. When a rule's endpoint_service comes from a computed value
# (e.g. a VPC endpoint service created in the same apply), it is unknown until apply, so such rules must set
# an explicit "key". Rules without a key fall back to the endpoint_service / resource_names value, which
# preserves the map keys of existing statically-defined rules.
resource "databricks_mws_ncc_private_endpoint_rule" "this" {
  for_each = { for rule in var.private_endpoint_rules : (rule.key != null ? rule.key : (rule.endpoint_service != null ? rule.endpoint_service : join(",", rule.resource_names))) => rule }

  network_connectivity_config_id = databricks_mws_network_connectivity_config.ncc.network_connectivity_config_id
  domain_names                   = each.value.domain_names
  endpoint_service               = each.value.endpoint_service
  resource_names                 = each.value.resource_names
}