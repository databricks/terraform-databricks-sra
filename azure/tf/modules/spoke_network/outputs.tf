output "ipgroup_cidrs" {
  description = "A map containing the CIDRs for the host and container IP groups, used for network segmentation in Azure."
  value = var.ipgroup_id != null ? {
    ipgroup_host_cidr      = azurerm_ip_group_cidr.host.cidr
    ipgroup_container_cidr = azurerm_ip_group_cidr.container.cidr
  } : null
}

output "resource_group_name" {
  description = "Name of deployed resource group"
  value       = azurerm_resource_group.this.name
}

output "dns_zone_ids" {
  description = "Private DNS Zone IDs"
  value = {
    dfs     = azurerm_private_dns_zone.dbfs_dfs.id
    blob    = azurerm_private_dns_zone.dbfs_blob.id
    backend = azurerm_private_dns_zone.backend.id
  }
}

output "subnet_ids" {
  description = "Subnet IDs"
  value = {
    host        = azurerm_subnet.host.id
    container   = azurerm_subnet.container.id
    privatelink = azurerm_subnet.privatelink.id
  }
}

output "subnet_names" {
  description = "Subnet names"
  value = {
    host        = azurerm_subnet.host.name
    container   = azurerm_subnet.container.name
    privatelink = azurerm_subnet.privatelink.name
  }
}

output "resource_suffix" {
  description = "Resource suffix to use for naming down stream resources"
  value       = var.resource_suffix
}

output "tags" {
  description = "Tags of this spoke"
  value       = var.tags
}

output "vnet_name" {
  description = "Name of the VNet"
  value       = azurerm_virtual_network.this.name
}

output "public_subnet_network_security_group_association_id" {
  description = "ID of the public subnet network security group association"
  value       = azurerm_subnet_network_security_group_association.host.id
}

output "private_subnet_network_security_group_association_id" {
  description = "ID of the private subnet network security group association"
  value       = azurerm_subnet_network_security_group_association.container.id
}

output "network_configuration" {
  description = "Network configuration for use with the workspace module"
  value = {
    virtual_network_name                                 = azurerm_virtual_network.this.name
    private_subnet_name                                  = azurerm_subnet.container.name
    public_subnet_name                                   = azurerm_subnet.host.name
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.container.id
    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.host.id
    private_endpoint_subnet_name                         = azurerm_subnet.privatelink.name
  }
}
