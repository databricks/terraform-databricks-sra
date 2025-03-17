<<<<<<< HEAD
<<<<<<< HEAD
=======
output "client_config" {
  value       = data.azurerm_client_config.current
  description = "The client configuration for the current Azure session, including subscription and authentication details."
}

>>>>>>> 60cc2bc (remove redundant module naming)
=======
>>>>>>> 8d44021 (serverless and classic compute working)
output "firewall_name" {
  value       = length(azurerm_firewall.this) > 0 ? azurerm_firewall.this[0].name : ""
  description = "The name of the Azure Firewall resource."
}

output "ipgroup_id" {
  value       = azurerm_ip_group.this.id
  description = "The unique ID of the Azure IP Group."
}

output "route_table_id" {
  value       = azurerm_route_table.this.id
  description = "The unique ID of the Azure Route Table."
}

output "key_vault_id" {
  value       = length(azurerm_key_vault.this) > 0 ? azurerm_key_vault.this[0].id : null
  description = "The ID of the Azure Key Vault, if created. Returns null if no Key Vault is created."
}

output "managed_disk_key_id" {
  value       = length(azurerm_key_vault_key.managed_disk) > 0 ? azurerm_key_vault_key.managed_disk[0].id : null
  description = "The ID of the Key Vault key used for managed disks, if available. Returns null if not created."
}

output "managed_services_key_id" {
  value       = length(azurerm_key_vault_key.managed_services) > 0 ? azurerm_key_vault_key.managed_services[0].id : null
  description = "The ID of the Key Vault key used for managed services, if available. Returns null if not created."
}

output "vnet_id" {
  value       = azurerm_virtual_network.this.id
  description = "The unique ID of the Azure Virtual Network."
}

output "vnet_name" {
  value       = azurerm_virtual_network.this.name
  description = "The name of the Azure Virtual Network."
}

output "metastore_id" {
<<<<<<< HEAD
<<<<<<< HEAD
  value       = length(databricks_metastore.this) > 0 ? databricks_metastore.this[0].id : null
=======
  value = length(databricks_metastore.this) > 0 ? databricks_metastore.this[0].id : null
>>>>>>> 60cc2bc (remove redundant module naming)
=======
  value       = length(databricks_metastore.this) > 0 ? databricks_metastore.this[0].id : null
>>>>>>> 900395d (naming)
  description = "The unique ID of the Databricks Metastore."
}

output "is_unity_catalog_enabled" {
<<<<<<< HEAD
<<<<<<< HEAD
  value       = var.is_unity_catalog_enabled
  description = "If UC creation is enabled"
}

<<<<<<< HEAD
=======
  value = var.is_unity_catalog_enabled
=======
  value       = var.is_unity_catalog_enabled
>>>>>>> 900395d (naming)
  description = "If UC creation is enabled"
}


>>>>>>> 60cc2bc (remove redundant module naming)
=======
>>>>>>> 76eb303 (style(azure): various whitespace/styling updates)
output "resource_group_name" {
  value       = azurerm_resource_group.this.name
  description = "The name of the Azure Resource Group."
}

output "private_link_info" {
  value = {
    dns_zone_id = azurerm_private_dns_zone.auth_front.id
    subnet_id   = azurerm_subnet.privatelink.id
  }
  description = "Information related to the Private Link, including DNS Zone ID and Subnet ID for Private Link connectivity."
}
<<<<<<< HEAD

<<<<<<< HEAD
<<<<<<< HEAD
output "dns_zone_ids" {
  description = "Private DNS Zone IDs"
  value = {
    dfs     = azurerm_private_dns_zone.dbfs_dfs[0].id,
    blob    = azurerm_private_dns_zone.dbfs_blob[0].id,
    backend = azurerm_private_dns_zone.auth_front.id
  }
}

output "ncc_id" {
  description = "NCC ID of this workspace"
  value       = databricks_mws_network_connectivity_config.this.network_connectivity_config_id
}

output "subnet_ids" {
  description = "Subnet IDs"
  value = {
    host        = azurerm_subnet.host.id
    container   = azurerm_subnet.container.id
    privatelink = azurerm_subnet.privatelink.id
  }
}

output "tags" {
  description = "Tags used in hub"
  value       = var.tags
}

output "workspace_url" {
  description = "The URL of the Databricks workspace, used to access the Databricks environment."
  value       = azurerm_databricks_workspace.webauth.workspace_url
}

output "workspace_id" {
  value       = azurerm_databricks_workspace.webauth.workspace_id
  description = "Workspace ID of the created workspace, according to the Databricks account console"
}

output "resource_suffix" {
  description = "Resource suffix to use for naming down stream resources"
  value       = var.resource_suffix
=======
output "tenant_id" {
  value       = local.tenant_id
  description = "The tenant ID of the Azure subscription, identifying the Azure AD instance."
=======
output "ncc_id" {
  value       = databricks_mws_network_connectivity_config.this.network_connectivity_config_id
  description = "The ID of the hub regional Network Connectivity Config."
>>>>>>> 8d44021 (serverless and classic compute working)
}
<<<<<<< HEAD

output "my_ip_addr" {
  value = local.ifconfig_co_json.ip
>>>>>>> 60cc2bc (remove redundant module naming)
}
=======
>>>>>>> 6df143a (deployed without UC)
=======
>>>>>>> 1942ef7 (feat(azure): Remove default storage from metastore)
