# This module is loosely based on https://medium.com/@lbrown22_18418/auto-approving-private-endpoints-using-terraform-e79d9f61d5dd

locals {
  pe_name = [for pe in data.azapi_resource.this.output.properties.privateEndpointConnections : pe.name if endswith(pe.properties.privateEndpoint.id, databricks_mws_ncc_private_endpoint_rule.this.endpoint_name)][0]
  update_body = {
    properties = {
      privateLinkServiceConnectionState = {
        description = "Approved for Databricks NCC ${var.network_connectivity_config_name}"
        status      = "Approved"
      }
    }
  }
}

resource "databricks_mws_ncc_private_endpoint_rule" "this" {
  network_connectivity_config_id = var.network_connectivity_config_id
  resource_id                    = var.resource_id
  group_id                       = var.group_id
}

data "azapi_resource" "this" {
  type                   = var.data_api_type
  resource_id            = var.resource_id
  response_export_values = ["properties.privateEndpointConnections"]
  depends_on             = [databricks_mws_ncc_private_endpoint_rule.this]
}

resource "azapi_update_resource" "this" {
  type      = var.update_api_type
  name      = local.pe_name
  parent_id = var.resource_id
  body      = local.update_body
}
