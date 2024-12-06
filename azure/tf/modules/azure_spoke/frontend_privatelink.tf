# resource "azurerm_private_endpoint" "frontend" {
#   count               = is_frontend_private_link_enabled ? 1 : 0
#   name                = "${var.prefix}-frontend"
#   location            = var.location
#   resource_group_name = var.hub_resource_group_name
#   subnet_id           = var.hub_private_link_info.subnet_id

#   private_service_connection {
#     name                           = "ple-${var.prefix}-front"
#     private_connection_resource_id = azurerm_databricks_workspace.this.id
#     is_manual_connection           = false
#     subresource_names              = ["databricks_ui_api"]
#   }

#   private_dns_zone_group {
#     name                 = "private-dns-zone-front"
#     private_dns_zone_ids = [var.hub_private_link_info.dns_zone_id]
#   }
# }
