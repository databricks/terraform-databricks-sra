# Inbound Private Link for performance-intensive services (Service Direct), such as Lakebase Autoscaling and Zerobus
# Ingest. A private endpoint in the hub privatelink subnet connects to the regional Databricks Private Link Service, is
# registered with the Databricks account (which approves the pending connection), and is published in DNS as
# <region>.service-direct.privatelink.azuredatabricks.net.
# See https://learn.microsoft.com/en-us/azure/databricks/security/network/front-end/service-direct-privatelink
locals {
  service_direct_private_link_service_id = "/subscriptions/7a725ef2-ea63-4500-8db6-0952563ee5f1/resourceGroups/regional_ingress_${var.location}_resource_group/providers/Microsoft.Databricks/workspaces/regional_ingress_${var.location}_workspace"
  service_direct_dns_record_name         = "${var.location}.service-direct"
}

resource "azurerm_private_endpoint" "service_direct" {
  count = var.is_service_direct_enabled ? 1 : 0

  name                = "${module.naming.private_endpoint.name}-service-direct"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = module.hub_network.subnet_ids["privatelink"]

  # The connection stays Pending until the endpoint is registered with the Databricks account below.
  private_service_connection {
    name                           = "service-direct"
    private_connection_resource_id = local.service_direct_private_link_service_id
    is_manual_connection           = true
    subresource_names              = ["service_direct"]
    request_message                = "Databricks SRA Service Direct private endpoint"
  }

  tags = var.tags
}

# azurerm does not expose the private endpoint's resourceGuid, which Databricks requires for registration.
data "azapi_resource" "service_direct" {
  count = var.is_service_direct_enabled ? 1 : 0

  type                   = "Microsoft.Network/privateEndpoints@2024-05-01"
  resource_id            = azurerm_private_endpoint.service_direct[0].id
  response_export_values = ["properties.resourceGuid"]
}

resource "databricks_endpoint" "service_direct" {
  count = var.is_service_direct_enabled ? 1 : 0

  parent = "accounts/${var.databricks_account_id}"
  # RFC-1034: letters, numbers, and hyphens; starts with a letter; ends with a letter or number; max 63 characters.
  display_name = replace(substr("sd-${var.location}-${replace(var.resource_suffix, "/[^a-zA-Z0-9-]/", "-")}", 0, 63), "/-+$/", "")
  region       = var.location

  azure_private_endpoint_info = {
    private_endpoint_name          = azurerm_private_endpoint.service_direct[0].name
    private_endpoint_resource_guid = data.azapi_resource.service_direct[0].output.properties.resourceGuid
  }
}

resource "azurerm_private_dns_a_record" "service_direct" {
  count = var.is_service_direct_enabled ? 1 : 0

  name                = local.service_direct_dns_record_name
  zone_name           = var.private_dns_zone_names.backend
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.service_direct[0].private_service_connection[0].private_ip_address]

  tags = var.tags

  depends_on = [module.hub_network]
}
